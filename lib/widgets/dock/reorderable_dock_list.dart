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
    this.itemSpacing = 8.0,
    required this.itemWidth,
    this.dragScale = 1.2,
  }) : super(key: key);

  @override
  State<ReorderableDockList> createState() => _ReorderableDockListState();
}

class _ReorderableDockListState extends State<ReorderableDockList> with TickerProviderStateMixin {
  int? _draggedIndex;
  int? _targetIndex;
  late List<GlobalKey> _itemKeys;
  
  late AnimationController _scaleController;
  
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
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  double _getItemScale(int index) {
    if (_draggedIndex == null || _targetIndex == null) return 1.0;
    
    final distance = (index - _targetIndex!).abs();
    if (distance == 1) {
      return 1.0 + (0.2 * _scaleController.value);
    }
    return 1.0;
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
      childWhenDragging: Opacity(
        opacity: 0.3,
        child: child,
      ),
      onDragStarted: () {
        setState(() => _draggedIndex = index);
      },
      onDragEnd: (_) {
        setState(() {
          _draggedIndex = null;
          _targetIndex = null;
        });
      },
      child: child,
    );
  }

  Widget _buildDragTarget(int index, Widget child) {
    return DragTarget<int>(
      builder: (context, candidateData, rejectedData) {
        return AnimatedScale(
          scale: _getItemScale(index),
          duration: const Duration(milliseconds: 150),
          child: child,
        );
      },
      onWillAccept: (data) {
        if (data == null || data == index) return false;
        setState(() => _targetIndex = index);
        _scaleController.forward(from: 0.0);
        return true;
      },
      onLeave: (_) {
        setState(() => _targetIndex = null);
        _scaleController.reverse();
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
        items.add(SizedBox(width: widget.itemSpacing));
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
