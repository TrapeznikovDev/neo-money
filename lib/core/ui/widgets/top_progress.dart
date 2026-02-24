import 'package:flutter/material.dart';
import 'package:neomoney/core/ui/theme/app_colors.dart';
import 'package:neomoney/core/ui/theme/app_text_styles.dart';

class TopProgress extends StatelessWidget {
  final int step;
  final int total;
  final String probabilityText;
  final String firstTitle;
  final String secondTitle;

  const TopProgress({
    super.key,
    required this.step,
    required this.total,
    required this.probabilityText,
    required this.firstTitle,
    required this.secondTitle,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (total == 0) ? 0.0 : (step / total).clamp(0.0, 1.0);

    return Column(
      children: [
        Text(
          firstTitle,
          textAlign: TextAlign.center,
          style: AppTypography.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700, fontSize: 22),
        ),
        SizedBox(height: 5),
        Text(
          secondTitle,
          textAlign: TextAlign.center,
          style: AppTypography.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        SizedBox(height: 10),
        _PillProgress(value: progress, text: probabilityText),
      ],
    );
  }
}

class _PillProgress extends StatelessWidget {
  final double value; // 0..1
  final String text;

  const _PillProgress({required this.value, required this.text});

  @override
  Widget build(BuildContext context) {
    const h = 30.0;
    final radius = BorderRadius.circular(h / 2);

    return ClipRRect(
      borderRadius: radius,
      child: SizedBox(
        height: h,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // серый фон (правая часть)
            Container(
              color: const Color(0xFF5F6473),
            ),

            // зелёная заполненная часть (левая)
            Align(
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: value,
                child: Container(
                  color: AppColors.primary,
                ),
              ),
            ),

            // текст поверх
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  text,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13, decorationThickness: 2),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
