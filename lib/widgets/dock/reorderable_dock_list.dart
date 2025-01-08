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
    this.itemSpacing = 16.0,
    required this.itemWidth,
    this.dragScale = 1.2,
  }) : super(key: key);

  @override
  State<ReorderableDockList> createState() => _ReorderableDockListState();
}

class _ReorderableDockListState extends State<ReorderableDockList> with TickerProviderStateMixin {
  int? _draggedIndex;
  int? _targetIndex;
  double? _dragPosition;
  late List<GlobalKey> _itemKeys;
  
  late AnimationController _scaleController;
  late AnimationController _spaceController;
  
  @override
  void initState() {
    super.initState();
    _itemKeys = List.generate(
      widget.children.length,
      (index) => GlobalKey(debugLabel: 'item_$index'),
    );
    
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );

    _spaceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _spaceController.dispose();
    super.dispose();
  }

  double _getItemScale(int index) {
    if (_draggedIndex == null || _targetIndex == null) return 1.0;
    
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
    final expandedSpacing = normalSpacing * 8;
    
    if (index == _targetIndex) {
      final curvedValue = Curves.easeOutBack.transform(_spaceController.value);
      return normalSpacing + (expandedSpacing - normalSpacing) * curvedValue;
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

  Widget _buildDraggableItem(int index, Widget child) {
    return Draggable<int>(
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
        setState(() => _draggedIndex = index);
      },
      onDragEnd: (_) {
        setState(() {
          _draggedIndex = null;
          _targetIndex = null;
          _dragPosition = null;
        });
        _spaceController.reverse();
      },
      onDragUpdate: (details) {
        setState(() => _dragPosition = details.localPosition.dx);
      },
      child: Visibility(
        visible: _draggedIndex != index,
        maintainState: true,
        maintainAnimation: true,
        maintainSize: true,
        child: child,
      ),
    );
  }

  Widget _buildDragTarget(int index, Widget child) {
    return DragTarget<int>(
      builder: (context, candidateData, rejectedData) {
        return TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 150),
          tween: Tween<double>(
            begin: 0.0,
            end: _getItemOffset(index),
          ),
          builder: (context, offset, child) {
            return Transform.translate(
              offset: Offset(offset, 0),
              child: AnimatedScale(
                scale: _getItemScale(index),
                duration: const Duration(milliseconds: 150),
                curve: Curves.easeOutCubic,
                child: child,
              ),
            );
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
        final newIndex = index;
        if (draggedIndex != newIndex) {
          widget.onReorder(draggedIndex, newIndex);
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
            duration: const Duration(milliseconds: 150),
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
