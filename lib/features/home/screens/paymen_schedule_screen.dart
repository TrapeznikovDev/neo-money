import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:neomoney/app/di.dart';
import 'package:neomoney/core/presentation/base_bloc_page.dart';
import 'package:neomoney/core/presentation/state/ui_state.dart';
import 'package:neomoney/core/ui/theme/app_colors.dart';
import 'package:neomoney/core/ui/theme/app_text_styles.dart';
import 'package:neomoney/features/home/screens/main/data/cubit/orders_cubit.dart';
import 'package:neomoney/features/home/screens/main/data/cubit/orders_state.dart';
import 'package:neomoney/features/home/screens/main/widgets/payment_item_widget.dart';

class PaymentScheduleScreen extends BaseBlocPage<OrdersCubit, OrdersState> {
  final int orderId;

  const PaymentScheduleScreen({super.key, required this.orderId});

  @override
  OrdersCubit createBloc(BuildContext context) => getIt<OrdersCubit>();

  @override
  String? get title => 'График платежей';

  @override
  Widget buildBody(BuildContext context, OrdersState state) {
    // чтобы не дергать каждый build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cubit = context.read<OrdersCubit>();
      if (cubit.state.paymentsStatus == UiStatus.initial) {
        cubit.fetchPaymentScheduleNf(orderId);
      }
    });

    final status = state.paymentsStatus;

    if (status == UiStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (status == UiStatus.failure) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              state.paymentsErrorMessage ?? 'Не удалось загрузить график платежей',
              style: AppTypography.textTheme.bodyMedium?.copyWith(color: AppColors.error),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => context.read<OrdersCubit>().fetchPaymentScheduleNf(orderId),
              child: const Text('Повторить'),
            ),
          ],
        ),
      );
    }

    final payments = state.payments;
    if (payments.isEmpty) {
      return const Center(child: Text('Нет данных для отображения'));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: payments.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) => PaymentItemWidget(item: payments[index]),
    );
  }
}