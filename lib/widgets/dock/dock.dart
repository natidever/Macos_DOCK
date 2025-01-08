import 'package:flutter/material.dart';
import 'dock_item.dart';
import 'dock_theme.dart';
import 'reorderable_dock_list.dart';

class Dock extends StatefulWidget {
  final List<Widget> children;
  final DockTheme? theme;
  final ValueChanged<int>? onItemSelected;
  final int? selectedIndex;

  const Dock({
    Key? key,
    required this.children,
    this.theme,
    this.onItemSelected,
    this.selectedIndex,
  }) : super(key: key);

  @override
  State<Dock> createState() => _DockState();
}

class _DockState extends State<Dock> {
  late List<Widget> _items;

  @override
  void initState() {
    super.initState();
    _items = List.from(widget.children);
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      final item = _items.removeAt(oldIndex);
      _items.insert(newIndex, item);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme ?? DockTheme.of(context);

    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Container(
          decoration: BoxDecoration(
            color: theme.backgroundColor.withOpacity(theme.backgroundOpacity),
            borderRadius: BorderRadius.circular(theme.borderRadius),
          ),
          padding: theme.padding,
          child: ReorderableDockList(
            itemWidth: theme.baseIconSize,
            itemSpacing: theme.spacing,
            dragScale: theme.maxIconScale,
            onReorder: _onReorder,
            children: List.generate(_items.length, (index) {
              return DockItem(
                baseSize: theme.baseIconSize,
                maxScale: theme.maxIconScale,
                isSelected: widget.selectedIndex == index,
                onTap: () => widget.onItemSelected?.call(index),
                child: _items[index],
              );
            }),
          ),
        ),
      ),
    );
  }
}
