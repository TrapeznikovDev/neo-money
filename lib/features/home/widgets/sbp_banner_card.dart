import 'package:flutter/material.dart';
import 'package:neomoney/core/ui/theme/app_colors.dart';
import 'package:neomoney/core/ui/theme/app_text_styles.dart';

class SbpBannerCard extends StatelessWidget {
  final String sbpAssetPath;
  final String title;
  final String subtitle;
  final String buttonText;
  final VoidCallback onPressed;

  const SbpBannerCard({
    super.key,
    required this.sbpAssetPath,
    required this.title,
    required this.buttonText,
    required this.onPressed,
    this.subtitle = 'Данные защищены сквозным шифрованием\nи передаются по безопасному соединению',
  });

  @override
  Widget build(BuildContext context) {
    final base = AppTypography.textTheme.labelSmall ?? const TextStyle();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              SizedBox(width: 20),
              Image.asset(sbpAssetPath),
              Expanded(
                child: Text(
                  title,
                  textAlign: TextAlign.right,
                  style: AppTypography.textTheme.bodySmall?.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child:
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: base.copyWith(
                    fontWeight: FontWeight.w500,
                    fontSize: 7,
                  ),
                )
              ),

              SizedBox(
                width: 130,
                height: 40,
                child: ElevatedButton(
                  onPressed: onPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF63B431),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22),
                    ),
                    elevation: 0,
                    padding: EdgeInsets.zero,
                  ),
                  child: Text(
                    buttonText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.textTheme.titleSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}