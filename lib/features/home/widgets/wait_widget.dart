// waiting_status_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:neomoney/core/ui/theme/app_colors.dart';
import 'package:neomoney/core/ui/theme/app_text_styles.dart';
import 'package:neomoney/features/home/screens/main/data/cubit/orders_cubit.dart';
import 'package:neomoney/features/home/screens/main/data/models/order_model.dart';
import 'package:neomoney/features/home/screens/main/widgets/app_card_container.dart';

class WaitingStatusWidget extends StatelessWidget {
  final OrderModel order;

  const WaitingStatusWidget({
    super.key,
    required this.order,
  });

  @override
  Widget build(BuildContext context) {
    final title = order.status == 'Одобрено'
        ? 'Договор подписан!\nОжидайте, мы переводим\nВам займ на карту!'
        : 'Ваша заявка находится \nна рассмотрении...';

    return AppCardContainer(
      padding: const EdgeInsets.all(20),
      borderRadius: BorderRadius.circular(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  title,
                  textAlign: TextAlign.left,
                  style: AppTypography.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                    height: 1.15,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Image.asset(
                'assets/icons/wait_icon.png',
                width: 45,
                height: 45,
                fit: BoxFit.contain,
              ),
            ],
          ),
          const SizedBox(height: 16),

          SizedBox(
            height: 54,
            child: ElevatedButton(
              onPressed: () => context.read<OrdersCubit>().refresh(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              ),
              child: Text(
                'Обновить',
                style: AppTypography.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}