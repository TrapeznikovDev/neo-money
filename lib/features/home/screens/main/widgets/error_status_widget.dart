import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:neomoney/core/presentation/state/ui_state.dart';
import 'package:neomoney/core/ui/theme/app_colors.dart';
import 'package:neomoney/core/ui/theme/app_text_styles.dart';

import 'package:neomoney/features/home/screens/main/data/cubit/orders_cubit.dart';
import 'package:neomoney/features/home/screens/main/data/cubit/orders_state.dart';
import 'package:neomoney/features/home/screens/main/data/models/order_model.dart';

import 'package:neomoney/features/home/screens/main/widgets/app_card_container.dart';

class ErrorStatusWidget extends StatefulWidget {
  final int? statusCode;
  final OrderModel? order;

  const ErrorStatusWidget({
    super.key,
    this.statusCode,
    this.order,
  });

  @override
  State<ErrorStatusWidget> createState() => _ErrorStatusWidgetState();
}

class _ErrorStatusWidgetState extends State<ErrorStatusWidget> {
  String _titleByStatus(int? status) {
    switch (status) {
      case 11:
        return 'При переводе произошла ошибка!';
      default:
        return 'Ошибка подключения';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: AppCardContainer(
        backgroundColor: Colors.white,
        borderRadius: BorderRadius.circular(20),
        showShadow: true,
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    _titleByStatus(widget.statusCode),
                    style: AppTypography.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: AppColors.secondary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.error_outline, color: AppColors.error),
                ),
              ],
            ),

            const SizedBox(height: 14),

            BlocBuilder<OrdersCubit, OrdersState>(
              builder: (context, state) {
                final isLoading = state.status == UiStatus.loading;

                return SizedBox(
                  height: 48,
                  width: double.infinity,
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
                      child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                    )
                        : const Text('Обновить'),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}