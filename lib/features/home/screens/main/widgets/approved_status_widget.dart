import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:neomoney/app/di.dart';
import 'package:neomoney/core/presentation/state/ui_state.dart';
import 'package:neomoney/core/ui/theme/app_colors.dart';
import 'package:neomoney/core/ui/theme/app_text_styles.dart';

import 'package:neomoney/features/home/screens/main/bloc/accept_order_bloc/accept_order_cubit.dart';
import 'package:neomoney/features/home/screens/main/bloc/accept_order_bloc/accept_order_effect.dart';
import 'package:neomoney/features/home/screens/main/bloc/accept_order_bloc/accept_order_state.dart';

import 'package:neomoney/features/home/screens/main/bloc/promocode_bloc/promocode_cubit.dart';

import 'package:neomoney/features/home/screens/main/bloc/timer_auth_bloc/timer_auth_cubit.dart';

import 'package:neomoney/features/home/screens/main/data/models/order_model.dart';
import 'package:neomoney/features/home/screens/main/data/cubit/orders_cubit.dart';

import 'package:neomoney/features/home/screens/main/widgets/app_card_container.dart';
import 'package:neomoney/features/home/screens/main/widgets/approved_sms_status.dart';

class ApprovedStatusWidget extends StatefulWidget {
  final OrderModel order;
  final VoidCallback onRefresh;
  final bool autoSubmit;

  const ApprovedStatusWidget({super.key, required this.order, required this.onRefresh, this.autoSubmit = false});

  @override
  State<ApprovedStatusWidget> createState() => _ApprovedStatusWidgetState();
}

class _ApprovedStatusWidgetState extends State<ApprovedStatusWidget> {
  late final TimerAuthCubit _timerCubit;
  late final PromoCodeCubit _promoCubit;

  late final double _min;
  late final double _max;
  late double _current;

  @override
  void initState() {
    super.initState();

    _timerCubit = getIt<TimerAuthCubit>();
    _promoCubit = getIt<PromoCodeCubit>();

    _min = (widget.order.minApprovedAmount ?? 1000).toDouble();
    final maxRaw = (widget.order.approvedAmount ?? widget.order.exceptAmount ?? 1000).toDouble();
    _max = maxRaw < _min ? _min : maxRaw;
    _current = _max;
  }

  @override
  Widget build(BuildContext context) {
    final int divisions = (((_max - _min) / 1000).floor()).clamp(1, 100);

    return MultiBlocProvider(
      providers: [
        BlocProvider<AcceptOrderCubit>(create: (_) => getIt<AcceptOrderCubit>()),
        BlocProvider<PromoCodeCubit>.value(value: _promoCubit),
      ],
      child: Builder(
        builder: (context) {
          final acceptCubit = context.read<AcceptOrderCubit>();

          if (widget.autoSubmit) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              final orderId = widget.order.orderId ?? 0;
              if (orderId == 0) return;
              acceptCubit.requestSms(amount: _current, orderId: orderId);
              _timerCubit.start(seconds: 30);
            });
          }

          return StreamBuilder<AcceptOrderEffect>(
            stream: acceptCubit.effects,
            builder: (context, snap) {
              final effect = snap.data;

              if (effect != null) {
                WidgetsBinding.instance.addPostFrameCallback((_) async {
                  if (!mounted) return;

                  if (effect is AcceptShowError) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(effect.message)));
                  }

                  if (effect is AcceptOpenSmsDialog) {
                    await showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (_) => MultiBlocProvider(
                        providers: [
                          BlocProvider.value(value: acceptCubit),
                          BlocProvider.value(value: _timerCubit), // если TimerAuthCubit не в дереве
                        ],
                        child: Dialog(
                          insetPadding: const EdgeInsets.all(16),
                          child: ApprovedSmsStatusWidget(
                            order: widget.order,
                            amount: effect.amount,
                            onOpenContract: () {
                              // TODO твой роут договора
                            },
                            onOpenDocs: () {
                              // TODO твой dialog/bottomsheet документов
                            },
                          ),
                        ),
                      ),
                    );
                  }

                  if (effect is AcceptCloseDialog) {
                    if (Navigator.of(context).canPop()) {
                      Navigator.of(context).pop();
                    }
                  }
                });
              }

              return BlocConsumer<AcceptOrderCubit, AcceptOrderState>(
                listenWhen: (p, n) {
                  final errChanged = (n.errorMessage?.isNotEmpty ?? false) != (p.errorMessage?.isNotEmpty ?? false);
                  final okChanged = n.success != p.success;
                  return errChanged || okChanged;
                },
                listener: (context, s) {
                  if (s.success) {
                    context.read<OrdersCubit>().refresh();
                    widget.onRefresh();
                  }
                },
                builder: (context, aState) {
                  final isLoading = aState.status == UiStatus.loading;

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AppCardContainer(
                        padding: EdgeInsets.zero,
                        backgroundColor: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        showShadow: true,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Header block
                            AppCardContainer(
                              useMaterial: false,
                              showShadow: false,
                              showBorder: false,
                              borderRadius: BorderRadius.circular(20),
                              backgroundColor: const Color(0xFFE5F3FF),
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          'Поздравляем!\nПо вашей заявке одобрено',
                                          style: AppTypography.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Container(
                                        width: 34,
                                        height: 34,
                                        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                                        child: const Icon(Icons.check, size: 18),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 14),

                                  Text(
                                    '${_max.toInt()} ₽',
                                    style: AppTypography.textTheme.displayMedium?.copyWith(fontSize: 36, fontWeight: FontWeight.w700),
                                  ),
                                  const SizedBox(height: 10),

                                  // if ((widget.order.activeDate ?? '').isNotEmpty)
                                  Text(
                                    'Вы можете принять решение до 14.02.2026',
                                    style: AppTypography.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 20),

                            if (_min != _max && _max > 1000) ...[
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Выберите сумму', style: AppTypography.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                                    Text('${_current.toInt()} ₽', style: AppTypography.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                                  ],
                                ),
                              ),
                              Slider(
                                value: _current.clamp(_min, _max),
                                min: _min,
                                max: _max,
                                divisions: divisions,
                                activeColor: AppColors.primary,
                                inactiveColor: AppColors.border,
                                onChanged: isLoading ? null : (v) => setState(() => _current = v),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('${_min.toInt()} ₽', style: AppTypography.textTheme.bodySmall),
                                    Text('${_max.toInt()} ₽', style: AppTypography.textTheme.bodySmall),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 10),
                            ],

                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: SizedBox(
                                height: 54,
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: isLoading
                                      ? null
                                      : () {
                                          final orderId = widget.order.orderId ?? 0;
                                          if (orderId == 0) {
                                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('orderId отсутствует')));
                                            return;
                                          }

                                          acceptCubit.requestSms(amount: _current, orderId: orderId);

                                          _timerCubit.start(seconds: 30);
                                        },
                                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                                  child: isLoading
                                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                                      : Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            const Text('Получить заем'),
                                            Text('${_current.toInt()} ₽', style: const TextStyle(fontWeight: FontWeight.w700)),
                                          ],
                                        ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 16),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      BlocBuilder<PromoCodeCubit, PromoCodeState>(
                        builder: (context, pState) {
                          final loading = pState.status == UiStatus.loading;

                          return AppCardContainer(
                            backgroundColor: const Color(0xFFE5F3FF),
                            borderRadius: BorderRadius.circular(20),
                            padding: const EdgeInsets.all(10),
                            child: AppCardContainer(
                              useMaterial: false,
                              showShadow: false,
                              borderRadius: BorderRadius.circular(18),
                              backgroundColor: Colors.white,
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Text('Ввести промокод', style: AppTypography.textTheme.bodySmall?.copyWith(color: AppColors.greyText)),
                                      InkWell(
                                        onTap: loading
                                            ? null
                                            : () => context.read<PromoCodeCubit>().apply(
                                                orderId: widget.order.orderId ?? 0,
                                                onApplied: widget.onRefresh,
                                              ),
                                        borderRadius: BorderRadius.circular(8),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                                          child: loading
                                              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                                              : Text(
                                                  'Применить',
                                                  style: AppTypography.textTheme.bodySmall?.copyWith(
                                                    color: AppColors.primary, // как на скрине (синий)
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 10),

                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: ConstrainedBox(
                                      constraints: BoxConstraints(
                                        maxWidth: MediaQuery.of(context).size.width * 0.5,
                                      ),
                                      child: TextField(
                                        controller: pState.controller,
                                        enabled: !loading,
                                        textInputAction: TextInputAction.done,
                                        style: AppTypography.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                                        decoration: InputDecoration(
                                          isDense: true,
                                          contentPadding: EdgeInsets.zero,
                                          hintText: 'Введите промокод',
                                          hintStyle: AppTypography.textTheme.titleMedium?.copyWith(
                                            fontWeight: FontWeight.w800,
                                            color: AppColors.greyText,
                                          ),
                                          filled: false,
                                          border: const UnderlineInputBorder(),
                                          enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.border)),
                                          focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.primary, width: 1.5)),
                                        ),
                                        onSubmitted: (_) {
                                          if (!loading) {
                                            context.read<PromoCodeCubit>().apply(orderId: widget.order.orderId ?? 0, onApplied: widget.onRefresh);
                                          }
                                        },
                                      ),
                                    ),
                                  ),

                                  if (pState.errorMessage?.isNotEmpty == true) ...[
                                    const SizedBox(height: 8),
                                    Text(pState.errorMessage!, style: AppTypography.textTheme.bodySmall?.copyWith(color: AppColors.error)),
                                  ],
                                  if (pState.success) ...[
                                    const SizedBox(height: 8),
                                    Text('Промокод применён', style: AppTypography.textTheme.bodySmall?.copyWith(color: Colors.green)),
                                  ],
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
