import 'package:flutter/material.dart';

class DockItem extends StatefulWidget {
  final Widget child;
  final double baseSize;
  final double maxScale;
  final VoidCallback? onTap;
  final String? label;
  final bool isSelected;

  const DockItem({
    Key? key,
    required this.child,
    this.baseSize = 48.0,
    this.maxScale = 1.1,
    this.onTap,
    this.label,
    this.isSelected = false,
  }) : super(key: key);

  @override
  State<DockItem> createState() => _DockItemState();
}

class _DockItemState extends State<DockItem> with SingleTickerProviderStateMixin {
  late AnimationController _bounceController;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
  }

  @override
  void dispose() {
    _bounceController.dispose();
    super.dispose();
  }

  void _triggerBounceAnimation() {
    _bounceController.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () {
          _triggerBounceAnimation();
          widget.onTap?.call();
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.label != null && _isHovered)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    widget.label!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            AnimatedScale(
              scale: _isHovered ? 1.2: 1.0,
              duration: const Duration(milliseconds: 150),
              curve: Curves.easeOutCubic,
              child: AnimatedBuilder(
                animation: _bounceController,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(
                      0,
                      -10 * _bounceController.value * (1 - _bounceController.value) * 4,
                    ),
                    child: child,
                  );
                },
                child: Container(
                  width: widget.baseSize,
                  height: widget.baseSize,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: widget.isSelected
                        ? [
                            BoxShadow(
                              color: Theme.of(context).primaryColor.withOpacity(0.5),
                              blurRadius: 8,
                              spreadRadius: 2,
                            )
                          ]
                        : null,
                  ),
                  child: widget.child,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
