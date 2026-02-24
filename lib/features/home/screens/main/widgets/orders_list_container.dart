import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:neomoney/app/di.dart';
import 'package:neomoney/app/router.dart';

import 'package:neomoney/core/presentation/state/ui_state.dart';
import 'package:neomoney/core/ui/theme/app_colors.dart';
import 'package:neomoney/core/ui/theme/app_text_styles.dart';
import 'package:neomoney/features/documents/data/cubit/doc_cubit/doc_cubit.dart';
import 'package:neomoney/features/home/screens/main/bloc/accept_order_bloc/accept_order_cubit.dart';
import 'package:neomoney/features/home/screens/main/bloc/timer_auth_bloc/timer_auth_cubit.dart';

import 'package:neomoney/features/home/screens/main/data/cubit/orders_cubit.dart';
import 'package:neomoney/features/home/screens/main/data/cubit/orders_state.dart';
import 'package:neomoney/features/home/screens/main/data/models/order_model.dart';
import 'package:neomoney/features/home/screens/main/widgets/approved_final_status.dart';
import 'package:neomoney/features/home/screens/main/widgets/approved_status_widget.dart';
import 'package:neomoney/features/home/screens/main/widgets/current_order_widget.dart';
import 'package:neomoney/features/home/screens/main/widgets/error_status_widget.dart';
import 'package:neomoney/features/home/screens/main/widgets/min_payment_docs_dialog.dart';
import 'package:neomoney/features/home/screens/main/widgets/min_payment_payment_dialog.dart';
import 'package:neomoney/features/home/widgets/cooler_widget.dart';
import 'package:neomoney/features/home/widgets/loan_calculator_card.dart';
import 'package:neomoney/features/home/widgets/loan_declined_card.dart';

class OrdersListContainer extends StatefulWidget {
  const OrdersListContainer({super.key, required this.scrollController, this.onOrderTap, this.autoRefreshInterval = const Duration(minutes: 3)});

  final ScrollController scrollController;
  final ValueChanged<OrderModel>? onOrderTap;
  final Duration autoRefreshInterval;

  @override
  State<OrdersListContainer> createState() => _OrdersListContainerState();
}

class _OrdersListContainerState extends State<OrdersListContainer> {
  Timer? _timer;

  // ===== DEBUG OVERRIDE =====
  static const bool _debugOverrideEnabled = false;
  static const int? _debugStatusCode = 9;
  static const int? _debugOnlyOrderIndex = 0;
  // static const bool _debugForceApprovedWidget = true;

  int _effectiveStatusCode(OrderModel order, int index) {
    if (!_debugOverrideEnabled) return order.statusCode ?? 0;

    if (_debugStatusCode == null) return order.statusCode ?? 0;

    if (_debugOnlyOrderIndex != null && index != _debugOnlyOrderIndex) {
      return order.statusCode ?? 0;
    }

    return _debugStatusCode!;
  }

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(widget.autoRefreshInterval, (_) {
      final cubit = context.read<OrdersCubit>();
      cubit.refresh();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  DateTime? _parseZaimDate(String? zaimDateString) {
    if (zaimDateString == null || zaimDateString.isEmpty) return null;
    try {
      final format = DateFormat("dd.MM.yyyy");
      return format.tryParse(zaimDateString) ?? DateTime.tryParse(zaimDateString);
    } catch (_) {
      return null;
    }
  }

  bool _shouldShowCalculator(OrderModel order) {
    final active = _parseZaimDate(order.activeDate);
    if (active == null) return false;
    final plus12 = active.add(const Duration(hours: 12));
    return DateTime.now().isAfter(plus12) && order.statusCode == 11;
  }

  bool _isAfterAvailableDate(OrderModel order) {
    final ad = order.availableDate;
    if (ad == null || ad.isEmpty) return false;

    try {
      final format = DateFormat("dd.MM.yyyy HH:mm:ss");
      final parsed = format.parse(ad);
      return DateTime.now().isAfter(parsed);
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OrdersCubit, OrdersState>(
      builder: (context, state) {
        final orders = state.orders;
        log(
          '[OrdersListContainer] orders count = ${orders.length}\n'
          '${orders.asMap().entries.map((e) {
            final o = e.value;
            return '''
[${e.key}]
id=${o.orderId}
status=${o.status}
statusCode=${o.statusCode}
confirmDate=${o.confirmDate}
exceptAmount=${o.exceptAmount}
noActive=${o.noActive}
''';
          }).join()}',
          name: 'ORDERS_DEBUG',
        );

        if (state.status == UiStatus.loading && orders.isEmpty) {
          return const Padding(
            padding: EdgeInsets.only(top: 25),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (orders.isEmpty) {
          return const Padding(padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8), child: _EmptyOrdersStub());
        }

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (widget.scrollController.hasClients) {
            widget.scrollController.animateTo(0, duration: const Duration(milliseconds: 250), curve: Curves.easeInOut);
          }
        });

        if (orders.length == 1) {
          final first = orders.first;

          final isAfter =
              _isAfterAvailableDate(first) ||
              ((first.availableDate == null || first.availableDate!.isEmpty) && (first.status == 'Нет открытых договоров'));

          final showCalc = _shouldShowCalculator(first);

          if (isAfter || showCalc) {
            return LoanCalculatorCard(min: 1000, max: 30000, initial: 30000, onAmountChanged: (int value) {}, onSubmit: () {}, onRulesTap: () {});
          }
        }

        return ListView.separated(
          controller: widget.scrollController,
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: orders.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final order = orders[index];

            // if (_debugForceApprovedWidget && index == 0) {
            //   return ApprovedStatusWidget(
            //     order: order,
            //     onRefresh: () {},
            //   );
            // }

            final statusCode = _effectiveStatusCode(order, index);

            if (statusCode == 13) {
              return _OrderCoolingDownStub(order: order);
            }

            if (order.noActive == true) {
              return _AddictionStatusStub(order: order);
            }

            if (order.status == 'Выдан') {
              final isNoContracts = (order.number == 'Нет открытых договоров');
              final hasNextPayment = (order.nextPayment != null && order.nextPayment != '01.01.0001');

              if (!isNoContracts && hasNextPayment) {
                return CurrentOrderWidget(
                  order: order,
                  ordersNum: orders.length,
                  haveCards: state.cards.isNotEmpty,
                  onMinPayment: () async {
                    if (state.cards.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Отсутствуют карты')));
                      return;
                    }

                    await PaymentDialog.show(
                      context,
                      order: order,
                      amount: (order.minAmount ?? 0).toDouble(),
                      action: 'MIN_PAY',
                      onAfterSuccessRefresh: () => context.read<OrdersCubit>().refresh(),
                    );
                  },
                  onFullPayment: () async {
                    if (state.cards.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Отсутствуют карты')),
                      );
                      return;
                    }

                    final fullAmount = (order.todayAmount ?? 0).toDouble(); // <-- проверь поле
                    if (fullAmount <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Сумма полного погашения недоступна')),
                      );
                      return;
                    }

                    await PaymentDialog.show(
                      context,
                      order: order,
                      amount: (order.todayAmount ?? 0).toDouble(),
                      action: 'FULL_PAY',
                      onAfterSuccessRefresh: () => context.read<OrdersCubit>().refresh(),
                    );
                  },
                  onOpenSchedule: () {
                    Navigator.of(context).pushNamed(AppRouteNames.paymentSchedule, arguments: order.orderId!);
                  },
                  onTap: widget.onOrderTap == null ? null : () => widget.onOrderTap!(order),
                );
              }

              return ApprovedStatusWidget(
                order: order,
                onRefresh: () {},
              );
            }
            if (statusCode == 3 && order.status == 'Отказано') {
              return DeclinedStatusWidget(order: order);
            }
            if (statusCode == 9 && order.status == 'Отказано') {
              return ApprovedFinalStatusWidget(order: order);
            }

            if (order.status == 'В ожидании' ||
                order.status == 'В обработке' ||
                order.status == 'Рассматривается' ||
                (order.status == 'Одобрено' && statusCode == 15)) {
              if (statusCode == 3) {
                return _CalcStub(order: order, onRefresh: () => context.read<OrdersCubit>().refresh());
              }
              return _WaitingStatusStub(order: order);
            }

            if (order.status == 'Одобрено') {
              if (statusCode == 7 || statusCode == 8 || statusCode == 10) {
                return ApprovedFinalStatusWidget(order: order);
              }
              if (statusCode == 11) {
                return ErrorStatusWidget(order: order, statusCode: statusCode,);
              }
              if (statusCode == 14) {
                return ErrorStatusWidget(order: order, statusCode: statusCode,);
              }
              if (statusCode == 3) {
                return DeclinedStatusWidget(order: order);
              }
              return _ApprovedStatusStub(order: order);
            }

            return const SizedBox.shrink();
          },
        );
      },
    );
  }
}

class _EmptyOrdersStub extends StatelessWidget {
  const _EmptyOrdersStub();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.secondary, borderRadius: BorderRadius.circular(16)),
      child: Text('Нет активных займов/заказов.', textAlign: TextAlign.center, style: AppTypography.textTheme.bodyMedium),
    );
  }
}

class _CalcStub extends StatelessWidget {
  const _CalcStub({required this.order, required this.onRefresh});

  final OrderModel order;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Калькулятор/повторная заявка', style: AppTypography.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text('Здесь будет твой CalcWidget', style: AppTypography.textTheme.bodyMedium),
          const SizedBox(height: 12),
          SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: onRefresh,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('Обновить'),
            ),
          ),
        ],
      ),
    );
  }
}

class _WaitingStatusStub extends StatelessWidget {
  const _WaitingStatusStub({required this.order});

  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    return _StatusCard(title: 'Заём в процессе', subtitle: order.status ?? 'В ожидании', icon: Icons.hourglass_top);
  }
}

class _ApprovedStatusStub extends StatelessWidget {
  const _ApprovedStatusStub({required this.order});

  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    return _StatusCard(title: 'Одобрено', subtitle: 'Ожидается подтверждение/подписание', icon: Icons.verified);
  }
}

class _PaymentErrorStatusStub extends StatelessWidget {
  const _PaymentErrorStatusStub({required this.order, this.canAddCard = false});

  final OrderModel order;
  final bool canAddCard;

  @override
  Widget build(BuildContext context) {
    return _StatusCard(
      title: 'Ошибка оплаты',
      subtitle: canAddCard ? 'Попробуйте добавить карту' : 'Попробуйте повторить оплату',
      icon: Icons.error,
      accent: AppColors.error,
    );
  }
}

class _AddictionStatusStub extends StatelessWidget {
  const _AddictionStatusStub({required this.order});

  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    return _StatusCard(title: 'Нет активного займа', subtitle: 'Можно оформить новый', icon: Icons.info);
  }
}

class _OrderCoolingDownStub extends StatelessWidget {
  const _OrderCoolingDownStub({required this.order});

  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    final confirmDate = order.confirmDate;
    return OrderCoolingDownWidget(confirmDate: confirmDate, order: order);
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.title, required this.subtitle, required this.icon, this.accent});

  final String title;
  final String subtitle;
  final IconData icon;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final c = accent ?? AppColors.primary;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, color: c),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(subtitle, style: AppTypography.textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
