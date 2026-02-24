import 'package:flutter/material.dart';
import 'package:neomoney/core/ui/theme/app_colors.dart';
import 'package:neomoney/core/ui/theme/app_text_styles.dart';

class MainButtonPrimary extends StatelessWidget {
  const MainButtonPrimary({
    super.key,
    required this.text,
    this.onPressed,
    this.isEnabled = true,
    this.height,
    this.padding,
    this.textStyle,
    this.isLoading = false,
    this.loadingWidget,
    this.borderRadius = 24,
  });

  final String text;
  final VoidCallback? onPressed;
  final bool isEnabled;

  final double? height;
  final EdgeInsetsGeometry? padding;

  final TextStyle? textStyle;

  /// аналог state==true
  final bool isLoading;

  /// аналог wid
  final Widget? loadingWidget;

  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final enabled = isEnabled && !isLoading;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(borderRadius),
        onTap: enabled ? onPressed : null,
        child: Container(
          height: height ?? 48,
          alignment: Alignment.center,
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            color: enabled ? AppColors.primary : AppColors.buttonColor,
          ),
          child: isLoading
              ? (loadingWidget ??
              const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2),
              ))
              : Text(
            text,
            style: (textStyle ??
                AppTypography.textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                )) ??
                const TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}