import 'package:flutter/material.dart';
import 'package:neomoney/core/ui/theme/app_colors.dart';
import 'package:neomoney/core/ui/theme/app_text_styles.dart';
import 'package:neomoney/features/home/screens/main/data/models/order_model.dart';

class CurrentOrderWidget extends StatelessWidget {
  const CurrentOrderWidget({
    super.key,
    required this.order,
    required this.ordersNum,
    required this.haveCards,
    this.onTap,
    required this.onMinPayment,
    required this.onFullPayment,
    this.onOpenSchedule,
  });

  final OrderModel order;
  final int ordersNum;
  final bool haveCards;

  final VoidCallback? onTap;
  final VoidCallback onMinPayment;
  final VoidCallback onFullPayment;
  final VoidCallback? onOpenSchedule;

  @override
  Widget build(BuildContext context) {
    final number = order.number ?? '';
    final totalDebt = order.totalDebt ?? 0;
    final nextPayment = order.nextPayment ?? '';

    return Material(
      color: AppColors.scaffold,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 6),
              )
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Текущий заём',
                      style: AppTypography.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                number,
                style: AppTypography.textTheme.bodyLarge?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 14),

              _RowText(
                left: 'Остаток основного долга',
                right: '$totalDebt ₽',
              ),
              const SizedBox(height: 8),
              _RowText(
                left: 'Дата планового платежа',
                right: nextPayment,
              ),

              if (onOpenSchedule != null && order.loanType == 'IL') ...[
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerLeft,
                  child: InkWell(
                    onTap: onOpenSchedule,
                    child: Text(
                      'График платежей',
                      style: AppTypography.textTheme.bodyMedium?.copyWith(
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 31),

              SizedBox(
                height: 63,
                child: ElevatedButton(
                  onPressed: haveCards ? onMinPayment : () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Отсутствуют карты')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.buttonColor,
                    foregroundColor: AppColors.textPrimary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
                    elevation: 0,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Минимальный\nплатёж',
                          style: AppTypography.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Text(
                        '${(order.minAmount ?? 0)} ₽',
                        style: AppTypography.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 13),

              SizedBox(
                height: 66,
                child: ElevatedButton(
                  onPressed: haveCards ? onFullPayment : () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Отсутствуют карты')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                  ),
                  child: Text(
                    ordersNum <= 1 ? 'Полное погашение и\nновая заявка' : 'Полное погашение',
                    textAlign: TextAlign.center,
                    style: AppTypography.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              if (ordersNum == 1) ...[
                const SizedBox(height: 10),
                Center(
                  child: InkWell(
                    onTap: haveCards ? onFullPayment : null,
                    child: Text(
                      'Полное погашение',
                      style: AppTypography.textTheme.bodySmall?.copyWith(
                        decoration: TextDecoration.underline,
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _RowText extends StatelessWidget {
  const _RowText({required this.left, required this.right,});

  final String left;
  final String right;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(left, style: AppTypography.textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)),
        ),
        const SizedBox(width: 12),
        Text(right, style:  AppTypography.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
      ],
    );
  }
}