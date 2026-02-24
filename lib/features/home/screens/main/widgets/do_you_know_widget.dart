import 'package:flutter/material.dart';
import 'package:neomoney/core/ui/theme/app_colors.dart';
import 'package:neomoney/core/ui/theme/app_text_styles.dart';

class DoYouKnowWidget extends StatelessWidget {
  const DoYouKnowWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(18), color: Colors.white),
      child: Column(
        children: [
          Row(
            children: [
              Text('?', style: AppTypography.textTheme.bodyLarge?.copyWith(color: AppColors.primary)),
              const SizedBox(height: 8),
              Text('Знаете ли вы, что', style: AppTypography.textTheme.bodyLarge?.copyWith(color: AppColors.primary)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'при регулярной оплате минимальных платежей в МФО ваша кредитная история становится лучше, рейтинг доверия повышается, а значит кредитный лимит будет максимальным.',
            style: AppTypography.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
