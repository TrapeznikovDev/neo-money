import 'package:flutter/material.dart';

/// Универсальная карточка-контейнер для переиспользования.

class AppCardContainer extends StatelessWidget {
  final Widget child;

  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;

  final Color? backgroundColor;

  final BorderRadiusGeometry borderRadius;

  final bool showBorder;
  final Color? borderColor;
  final double borderWidth;

  final bool showShadow;
  final List<BoxShadow>? boxShadow;

  final double? width;
  final double? height;

  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  /// Если хочешь, чтобы карточка была Material (для InkWell ripple).
  final bool useMaterial;

  const AppCardContainer({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.backgroundColor,
    this.borderRadius = const BorderRadius.all(Radius.circular(16)),
    this.showBorder = false,
    this.borderColor,
    this.borderWidth = 1,
    this.showShadow = false,
    this.boxShadow,
    this.width,
    this.height,
    this.onTap,
    this.onLongPress,
    this.useMaterial = true,
  });

  @override
  Widget build(BuildContext context) {
    final decoration = BoxDecoration(
      color: backgroundColor,
      borderRadius: borderRadius,
      border: showBorder
          ? Border.all(
        color: borderColor ?? Colors.black12,
        width: borderWidth,
      )
          : null,
      boxShadow: showShadow
          ? (boxShadow ??
          [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ])
          : null,
    );

    Widget content = Container(
      width: width,
      height: height,
      margin: margin,
      padding: padding,
      decoration: decoration,
      child: child,
    );

    final isClickable = onTap != null || onLongPress != null;

    if (!useMaterial && !isClickable) return content;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: (borderRadius is BorderRadius)
            ? borderRadius as BorderRadius
            : BorderRadius.circular(16),
        child: content,
      ),
    );
  }
}