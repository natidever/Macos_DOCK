import 'package:flutter/material.dart';

class DockTheme {
  final Color backgroundColor;
  final double backgroundOpacity;
  final double baseIconSize;
  final double maxIconScale;
  final double borderRadius;
  final EdgeInsets padding;
  final double spacing;

  const DockTheme({
    this.backgroundColor = Colors.black,
    this.backgroundOpacity = 0.2,
    this.baseIconSize = 48.0,
    this.maxIconScale = 1.5,
    this.borderRadius = 16.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    this.spacing = 8.0,
  });

  DockTheme copyWith({
    Color? backgroundColor,
    double? backgroundOpacity,
    double? baseIconSize,
    double? maxIconScale,
    double? borderRadius,
    EdgeInsets? padding,
    double? spacing,
  }) {
    return DockTheme(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      backgroundOpacity: backgroundOpacity ?? this.backgroundOpacity,
      baseIconSize: baseIconSize ?? this.baseIconSize,
      maxIconScale: maxIconScale ?? this.maxIconScale,
      borderRadius: borderRadius ?? this.borderRadius,
      padding: padding ?? this.padding,
      spacing: spacing ?? this.spacing,
    );
  }

  static DockTheme of(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark
        ? const DockTheme(
            backgroundColor: Colors.white,
            backgroundOpacity: 0.15,
          )
        : const DockTheme(
            backgroundColor: Colors.black,
            backgroundOpacity: 0.2,
          );
  }
}
