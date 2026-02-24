import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:neomoney/core/ui/theme/app_colors.dart';
import 'package:neomoney/core/ui/theme/app_text_styles.dart';
import 'package:neomoney/features/home/screens/main/data/models/order_model.dart';
import 'package:neomoney/features/home/screens/main/widgets/main_button_white.dart';

class DiscountStatusWidget extends StatelessWidget {
  const DiscountStatusWidget({
    super.key,
    required this.order,
    required this.onPayDiscount,
  });

  final OrderModel order;
  final VoidCallback onPayDiscount;

  @override
  Widget build(BuildContext context) {
    final discount = (order.discountAmount ?? 0).toDouble();
    final today = (order.todayAmount ?? 0).toDouble();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.buttonColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Вам доступна оплата со скидкой для закрытия займа',
            style: AppTypography.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Остаток задолженности\nс учетом скидки',
                style: AppTypography.textTheme.bodyMedium?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${_money(discount)} ₽',
                    style: AppTypography.textTheme.titleLarge?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_money(today)} ₽',
                    style: AppTypography.textTheme.bodyMedium?.copyWith(
                      color: Colors.black.withOpacity(0.35),
                      fontWeight: FontWeight.w700,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          MainButtonPrimary(
            text: 'Оплатить с учетом скидки • ${_money(discount)} ₽',
            onPressed: onPayDiscount,
          ),
        ],
      ),
    );
  }

  String _money(double value) {
    final f = NumberFormat("#,##0.##", "ru_RU");
    return f.format(value);
  }
}