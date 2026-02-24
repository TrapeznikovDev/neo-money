import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:neomoney/core/ui/theme/app_text_styles.dart';
import 'package:neomoney/features/home/cubit/order_timer/order_cooling_down_cubit.dart';
import 'package:neomoney/features/home/screens/main/data/models/order_model.dart';
import 'package:neomoney/features/home/screens/main/data/cubit/orders_cubit.dart';
import 'package:neomoney/app/di.dart';
import 'package:neomoney/features/home/widgets/wait_widget.dart';

class OrderCoolingDownWidget extends StatelessWidget {
  final String confirmDate;
  final OrderModel order;

  const OrderCoolingDownWidget({
    super.key,
    required this.confirmDate,
    required this.order,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider<OrderCoolingDownCubit>(
      create: (_) => getIt<OrderCoolingDownCubit>()..startTimer(confirmDate),
      child: BlocConsumer<OrderCoolingDownCubit, OrderCoolingDownState>(
        listenWhen: (prev, cur) {
          final errorAppeared = cur.error.isNotEmpty && prev.error.isEmpty;
          final becameSuccess = cur.success && !prev.success;
          return errorAppeared || becameSuccess;
        },
        listener: (context, state) {
          if (state.error.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error)),
            );
          }
          if (state.success) {
            // ✅ обновить список заказов в твоём стейте
            // замени load() на реальный метод твоего OrdersCubit
            context.read<OrdersCubit>().load();
          }
        },
        builder: (context, state) {
          final cubit = context.read<OrderCoolingDownCubit>();

          // 4 часа прошли / таймер закончился -> показываем финальный виджет
          if (state.timeLeft == '00:00:00') {
            return WaitingStatusWidget(order: order);
          }

          return _CoolingDownCard(
            timeLeft: state.timeLeft,
            isLoading: state.loading,
            onRefuse: () => cubit.refuseCoolingOrder(order.orderId ?? 0),
          );
        },
      ),
    );
  }
}

class _CoolingDownCard extends StatelessWidget {
  final String timeLeft;
  final bool isLoading;
  final VoidCallback onRefuse;

  const _CoolingDownCard({
    required this.timeLeft,
    required this.isLoading,
    required this.onRefuse,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Уважаемый заемщик!',
            style: AppTypography.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            'В соответствии с требованиями статьи 9.3 Федерального закона от 21.12.2013 г. № 353-ФЗ "О потребительском кредите (займе)" - передача денежных средств по договору займа будет осуществлена не ранее чем через 4 (четыре) часа после подписания одобренной заявки. Уведомляем, что в соответствии со статьей 9.4 Федерального закона от 21.12.2013 г. № 353-ФЗ "О потребительском кредите (займе)" Вы вправе отказаться от получения займа до истечения вышеуказанного срока. По истечении 4-х часов сумма займа будет автоматически перечислена выбранным Вами способом получения денег. Ожидайте!',
            style: AppTypography.textTheme.labelLarge,
          ),
          const SizedBox(height: 18),
          Align(
            alignment: Alignment.center,
            child: Text(
              timeLeft,
              style: const TextStyle(
                fontSize: 36,
                color: Colors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (isLoading)
            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2.5),
            )
          else
            Align(
              alignment: Alignment.center,
              child: InkWell(
                borderRadius: BorderRadius.circular(30),
                onTap: onRefuse,
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  child: Text(
                    'Отказаться',
                    style: TextStyle(
                      fontSize: 12,
                      decoration: TextDecoration.underline,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// 🔁 Заменишь на свой финальный виджет (у тебя он точно есть в проекте)
class _ApprovedFinalStatusWidget extends StatelessWidget {
  final OrderModel order;
  const _ApprovedFinalStatusWidget({required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F5F7),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Ожидайте, мы переводим\nВам деньги на карту',
            style: AppTypography.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => context.read<OrdersCubit>().load(),
            child: const Text('Обновить'),
          ),
        ],
      ),
    );
  }
}