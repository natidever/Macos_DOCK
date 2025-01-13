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
    this.baseSize = 64.0,
    this.maxScale = 1.2,
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
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (widget.label != null && _isHovered)
              Positioned(
                bottom: widget.baseSize + 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    widget.label!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            AnimatedScale(
              scale: _isHovered ? widget.maxScale : 1.0,
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
                  padding: EdgeInsets.all(widget.baseSize * 0.12),
                  decoration: BoxDecoration(
                    color: widget.isSelected 
                        ? Colors.white.withOpacity(0.15)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: widget.isSelected
                        ? [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: widget.child,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
