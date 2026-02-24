import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:neomoney/core/presentation/state/ui_state.dart';

import 'package:neomoney/core/ui/theme/app_colors.dart';
import 'package:neomoney/core/ui/theme/app_text_styles.dart';

import 'package:neomoney/features/home/screens/main/data/models/order_model.dart';
import 'package:neomoney/features/home/screens/main/data/cubit/orders_cubit.dart';
import 'package:neomoney/features/home/screens/main/data/cubit/orders_state.dart';
import 'package:neomoney/features/home/screens/main/widgets/app_card_container.dart';

class ApprovedFinalStatusWidget extends StatelessWidget {
  final OrderModel order;

  const ApprovedFinalStatusWidget({
    super.key,
    required this.order,
  });

  @override
  Widget build(BuildContext context) {
    return AppCardContainer(
      padding: const EdgeInsets.all(25),
      backgroundColor: AppColors.secondary,
      borderRadius: BorderRadius.circular(25),
      showBorder: true,
      borderColor: AppColors.border,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  'Ожидайте, мы переводим\nВам деньги на карту',
                  style: AppTypography.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                height: 40,
                width: 40,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                child: Center(
                  child: Image.asset(
                    'assets/icons/wait_icon.png',
                    width: 22,
                    height: 22,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          BlocBuilder<OrdersCubit, OrdersState>(
            builder: (context, s) {
              final isLoading = s.status == UiStatus.loading;

              return SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: isLoading ? null : () => context.read<OrdersCubit>().refresh(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: isLoading
                      ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                      : const Text('Обновить'),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}