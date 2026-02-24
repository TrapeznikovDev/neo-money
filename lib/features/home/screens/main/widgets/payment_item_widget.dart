import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:neomoney/core/ui/theme/app_colors.dart';
import 'package:neomoney/core/ui/theme/app_text_styles.dart';
import 'package:neomoney/features/home/screens/main/data/models/payment_item_model.dart';

class PaymentItemWidget extends StatelessWidget {
  final PaymentItemModel item;

  const PaymentItemWidget({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('d MMMM yyyy', 'ru');
    final currency = NumberFormat.currency(locale: 'ru_RU', symbol: '₽');

    return Container(
      decoration: BoxDecoration(
        color: AppColors.buttonColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.12)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      child: Column(
        children: [
          // top
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  dateFormat.format(item.paymentDate),
                  style: AppTypography.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
                Text(
                  'Платёж ${currency.format(item.paymentSum)}',
                  style: AppTypography.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          _row('Сумма тела займа', currency.format(item.loanBodySum)),
          const SizedBox(height: 8),
          _row('Сумма процентов', currency.format(item.percentSum)),

          const SizedBox(height: 12),

          // bottom
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Остаток после оплаты',
                  style: AppTypography.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
                Text(
                  currency.format(item.loanBalance),
                  style: AppTypography.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(String left, String right) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(left, style: AppTypography.textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
        Text(right, style: AppTypography.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
      ],
    );
  }
}