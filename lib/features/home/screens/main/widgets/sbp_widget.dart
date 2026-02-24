import 'package:flutter/material.dart';
import 'package:neomoney/core/ui/theme/app_colors.dart';
import 'package:neomoney/core/ui/theme/app_text_styles.dart';
import 'package:neomoney/features/home/screens/main/widgets/main_button_white.dart';

class SbpWidget extends StatelessWidget {
  const SbpWidget({
    super.key,
    required this.onChoose,
    this.isLoading = false,
  });

  final VoidCallback onChoose;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isMedium = screenHeight < 950 && screenHeight > 800;
    final isSmall = screenHeight < 800;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.buttonColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                // TODO: подставь свою картинку/иконку
                // Image.asset(Assets.sbp, height: 50)
                const SizedBox(height: 50, width: 50),
                const SizedBox(height: 8),
                Text(
                  'Данные защищены сквозным шифрованием\nи передаются по безопасному соединению',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: (isSmall || isMedium) ? 10 : 12,
                    color: Colors.black.withOpacity(0.45),
                    height: 1.15,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              children: [
                Text(
                  'Пользуйтесь СБП\nдля удобной оплаты',
                  textAlign: TextAlign.center,
                  style: AppTypography.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                    fontSize: (isSmall || isMedium) ? 14 : 16,
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: MainButtonPrimary(
                    text: 'Выбрать',
                    isLoading: isLoading,
                    onPressed: onChoose,
                    height: 40,
                    borderRadius: 18,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}