import 'package:flutter/material.dart';

class ReorderableDockList extends StatefulWidget {
  final List<Widget> children;
  final void Function(int oldIndex, int newIndex) onReorder;
  final double itemSpacing;
  final double itemWidth;
  final double dragScale;

  const ReorderableDockList({
    Key? key,
    required this.children,
    required this.onReorder,
    this.itemSpacing = 12.0,
    required this.itemWidth,
    this.dragScale = 1.2,
  }) : super(key: key);

  @override
  State<ReorderableDockList> createState() => _ReorderableDockListState();
}

class _ReorderableDockListState extends State<ReorderableDockList> with TickerProviderStateMixin {
  int? _draggedIndex;
  int? _targetIndex;
  int? _hoveredIndex;
  double? _dragPosition;
  Offset? _dragOffset;
  late List<GlobalKey> _itemKeys;
  
  // Track the release animation state
  int? _releasedIndex;
  Offset? _releaseStartPosition;
  Offset? _releaseEndPosition;
  
  // Track current positions of items for smooth animation
  final Map<int, Offset> _itemPositions = {};
  bool _isReordering = false;
  
  late AnimationController _scaleController;
  late AnimationController _spaceController;
  late AnimationController _hoverController;
  late AnimationController _releaseController;
  
  @override
  void initState() {
    super.initState();
    _itemKeys = List.generate(
      widget.children.length,
      (index) => GlobalKey(debugLabel: 'item_$index'),
    );
    
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800), // Increased from 200ms
    );

    _spaceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000), // Increased from 300ms
    );

    _hoverController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400), // Increased from 150ms
    );
    
    _releaseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200), // Increased from 600ms
    )..addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _releasedIndex = null;
          _releaseStartPosition = null;
          _releaseEndPosition = null;
          _isReordering = false;
          _itemPositions.clear();
        });
      }
    });
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _spaceController.dispose();
    _hoverController.dispose();
    _releaseController.dispose();
    super.dispose();
  }

  double _getItemScale(int index) {
    if (_draggedIndex == null || _targetIndex == null) {
      // Apply hover effect when not dragging
      if (_hoveredIndex != null) {
        final distance = (index - _hoveredIndex!).abs();
        if (distance <= 1) { // Affects current and adjacent items
          // Very subtle scale based on distance
          final hoverScale = distance == 0 ? 0.05 : 0.03;
          return 1.0 + (hoverScale * _hoverController.value);
        }
      }
      return 1.0;
    }
    
    final distance = (index - _targetIndex!).abs();
    if (distance == 1) {
      return 1.0 + (0.1 * _scaleController.value);
    }
    return 1.0;
  }

  double _getSpacing(int index) {
    if (_draggedIndex == null || _targetIndex == null) {
      return widget.itemSpacing;
    }

    final normalSpacing = widget.itemSpacing;
    final expandedSpacing = normalSpacing * 2.5;  // Reduced from 10x to 2.5x for smoother feel
    
    if (index == _targetIndex) {
      // Calculate proximity factor based on drag position
      double proximityFactor = 1.0;
      if (_dragOffset != null) {
        final targetRenderBox = _itemKeys[index].currentContext?.findRenderObject() as RenderBox?;
        if (targetRenderBox != null) {
          final targetCenter = targetRenderBox.localToGlobal(
            Offset(targetRenderBox.size.width / 2, targetRenderBox.size.height / 2),
          );
          final distance = (_dragOffset! - targetCenter).distance;
          // Smoothly interpolate spacing based on distance
          proximityFactor = (1.0 - (distance / (widget.itemWidth * 0.5))).clamp(0.0, 1.0);
        }
      }
      
      final curvedValue = Curves.easeOutCubic.transform(_spaceController.value);
      return normalSpacing + (expandedSpacing - normalSpacing) * curvedValue * proximityFactor;
    }
    
    return normalSpacing;
  }

  double _getItemOffset(int index) {
    if (_draggedIndex == null || _targetIndex == null) return 0.0;
    
    double offset = 0.0;
    final movingRight = _draggedIndex! < _targetIndex!;
    
    if (movingRight) {
      if (index > _draggedIndex! && index <= _targetIndex!) {
        for (int i = _draggedIndex! + 1; i < index; i++) {
          offset += _getSpacing(i) - widget.itemSpacing;
        }
        offset -= (widget.itemWidth + widget.itemSpacing) * Curves.easeOutBack.transform(_spaceController.value);
      }
    } else {
      if (index < _draggedIndex! && index >= _targetIndex!) {
        for (int i = index + 1; i <= _draggedIndex!; i++) {
          offset -= _getSpacing(i - 1) - widget.itemSpacing;
        }
        offset += (widget.itemWidth + widget.itemSpacing) * Curves.easeOutBack.transform(_spaceController.value);
      }
    }
    
    return offset;
  }

  void _updateItemPositions() {
    for (int i = 0; i < widget.children.length; i++) {
      final box = _itemKeys[i].currentContext?.findRenderObject() as RenderBox?;
      if (box != null) {
        _itemPositions[i] = box.localToGlobal(Offset.zero);
      }
    }
  }

  Widget _buildDraggableItem(int index, Widget child) {
    return MouseRegion(
      onEnter: (_) {
        setState(() => _hoveredIndex = index);
        _hoverController.forward();
      },
      onExit: (_) {
        setState(() => _hoveredIndex = null);
        _hoverController.reverse();
      },
      child: Draggable<int>(
        data: index,
        feedback: Transform.scale(
          scale: widget.dragScale,
          child: Material(
            color: Colors.transparent,
            child: child,
          ),
        ),
        childWhenDragging: const SizedBox(),
        onDragStarted: () {
          setState(() {
            _draggedIndex = index;
            _hoveredIndex = null;
          });
        },
        onDragEnd: (details) {
          // Capture the release position and target for smooth animation
          if (_targetIndex != null && _dragOffset != null) {
            final targetBox = _itemKeys[_targetIndex!].currentContext?.findRenderObject() as RenderBox?;
            if (targetBox != null) {
              final targetPosition = targetBox.localToGlobal(Offset.zero);
              setState(() {
                _releasedIndex = _draggedIndex;
                _releaseStartPosition = _dragOffset;
                _releaseEndPosition = targetPosition;
              });
              _releaseController.forward(from: 0.0);
            }
          }
          
          setState(() {
            _draggedIndex = null;
            _targetIndex = null;
            _dragPosition = null;
            _dragOffset = null;
          });
          
          _spaceController.reverse();
        },
        onDragUpdate: (details) {
          setState(() {
            _dragPosition = details.localPosition.dx;
            _dragOffset = details.globalPosition;
            
            // Find nearest target based on proximity
            if (_draggedIndex != null) {
              RenderBox? nearestTarget;
              int? nearestIndex;
              double minDistance = double.infinity;
              
              for (int i = 0; i < _itemKeys.length; i++) {
                if (i == _draggedIndex) continue;
                
                final itemBox = _itemKeys[i].currentContext?.findRenderObject() as RenderBox?;
                if (itemBox != null) {
                  final itemCenter = itemBox.localToGlobal(
                    Offset(itemBox.size.width / 2, itemBox.size.height / 2),
                  );
                  final distance = (_dragOffset! - itemCenter).distance;
                  
                  if (distance < minDistance && distance < (widget.itemWidth * 0.5)) {
                    minDistance = distance;
                    nearestTarget = itemBox;
                    nearestIndex = i;
                  }
                }
              }
              
              if (nearestIndex != null && nearestIndex != _targetIndex) {
                setState(() => _targetIndex = nearestIndex);
                _scaleController.forward(from: 0.0);
                _spaceController.forward(from: _spaceController.value);
              }
            }
          });
        },
        child: Visibility(
          visible: _draggedIndex != index,
          maintainState: true,
          maintainAnimation: true,
          maintainSize: true,
          child: child,
        ),
      ),
    );
  }

  Widget _buildDragTarget(int index, Widget child) {
    return DragTarget<int>(
      builder: (context, candidateData, rejectedData) {
        return TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 1000), // Increased from 300ms
          curve: Curves.easeOutCubic,
          tween: Tween<double>(
            begin: 0.0,
            end: _getItemOffset(index),
          ),
          builder: (context, offset, child) {
            Widget result = Transform.translate(
              offset: Offset(offset, 0),
              child: AnimatedScale(
                scale: _getItemScale(index),
                duration: const Duration(milliseconds: 800), // Increased from 200ms
                curve: Curves.easeOutCubic,
                child: child,
              ),
            );

            if (_isReordering && _itemPositions.containsKey(index)) {
              final startOffset = _itemPositions[index]!;
              final box = _itemKeys[index].currentContext?.findRenderObject() as RenderBox?;
              if (box != null) {
                final currentOffset = box.localToGlobal(Offset.zero);
                final diffOffset = currentOffset - startOffset;
                
                result = TweenAnimationBuilder<Offset>(
                  key: ValueKey('reorder_$index'),
                  duration: const Duration(milliseconds: 1200), // Increased from 600ms
                  curve: Curves.easeOutCubic,
                  tween: Tween<Offset>(
                    begin: -diffOffset,
                    end: Offset.zero,
                  ),
                  builder: (context, animOffset, child) {
                    return Transform.translate(
                      offset: animOffset,
                      child: child,
                    );
                  },
                  child: result,
                );
              }
            }
            
            return result;
          },
          child: child,
        );
      },
      onWillAccept: (data) {
        if (data == null || data == index) return false;
        setState(() => _targetIndex = index);
        _scaleController.forward(from: 0.0);
        _spaceController.forward(from: 0.0);
        return true;
      },
      onLeave: (_) {
        setState(() => _targetIndex = null);
        _scaleController.reverse();
        _spaceController.reverse();
      },
      onAccept: (draggedIndex) {
        if (draggedIndex != index) {
          // Capture current positions before reordering
          _updateItemPositions();
          setState(() => _isReordering = true);
          
          // Perform reorder with animation
          widget.onReorder(draggedIndex, index);
          
          // Start release animation
          _releaseController.forward(from: 0.0);
        }
      },
    );
  }

  List<Widget> _buildItems() {
    final items = <Widget>[];
    
    for (var i = 0; i < widget.children.length; i++) {
      if (i > 0) {
        items.add(
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 1000), // Increased from 300ms
            curve: Curves.easeOutCubic,
            tween: Tween<double>(
              begin: widget.itemSpacing,
              end: _getSpacing(i - 1),
            ),
            builder: (context, spacing, child) {
              return SizedBox(width: spacing);
            },
          ),
        );
      }
      
      final child = _buildDraggableItem(i, widget.children[i]);
      items.add(_buildDragTarget(i, child));
    }
    
    return items;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: _buildItems(),
    );
  }
}
