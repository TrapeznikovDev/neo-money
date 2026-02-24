// ignore_for_file: use_build_context_synchronously

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:neomoney/app/di.dart';
import 'package:neomoney/core/presentation/state/ui_state.dart';
import 'package:neomoney/core/ui/theme/app_colors.dart';
import 'package:neomoney/core/ui/theme/app_text_styles.dart';

import 'package:neomoney/features/home/screens/main/bloc/accept_order_bloc/accept_order_cubit.dart';
import 'package:neomoney/features/home/screens/main/bloc/accept_order_bloc/accept_order_effect.dart';
import 'package:neomoney/features/home/screens/main/bloc/accept_order_bloc/accept_order_state.dart';
import 'package:neomoney/features/home/screens/main/bloc/timer_auth_bloc/timer_auth_cubit.dart';

import 'package:neomoney/features/home/screens/main/data/models/order_model.dart';
import 'package:neomoney/features/home/screens/main/widgets/app_card_container.dart';

class ApprovedSmsStatusWidget extends StatefulWidget {
  final OrderModel order;
  final double amount;

  /// Открыть договор
  final VoidCallback onOpenContract;

  /// Открыть документы
  final VoidCallback onOpenDocs;

  const ApprovedSmsStatusWidget({
    super.key,
    required this.order,
    required this.amount,
    required this.onOpenContract,
    required this.onOpenDocs,
  });

  @override
  State<ApprovedSmsStatusWidget> createState() => _ApprovedSmsStatusWidgetState();
}

class _ApprovedSmsStatusWidgetState extends State<ApprovedSmsStatusWidget> {
  late final TextEditingController _smsController;
  bool _processing = false;

  TimerAuthCubit get _timerCubit => getIt<TimerAuthCubit>();

  @override
  void initState() {
    super.initState();
    _smsController = TextEditingController()..addListener(_onSmsChanged);
  }

  @override
  void dispose() {
    _smsController.removeListener(_onSmsChanged);
    _smsController.dispose();
    super.dispose();
  }

  void _onSmsChanged() {
    if (_processing) return;

    final text = _smsController.text;
    if (text.length == 4 && RegExp(r'^\d{4}$').hasMatch(text)) {
      _submitCode();
    }
    setState(() {}); // обновить enabled кнопки
  }

  Future<void> _submitCode() async {
    if (_processing) return;

    final orderId = widget.order.orderId ?? 0;
    if (orderId == 0) return;

    final codeStr = _smsController.text;
    if (!RegExp(r'^\d{4}$').hasMatch(codeStr)) return;

    FocusManager.instance.primaryFocus?.unfocus();

    setState(() => _processing = true);
    try {
      await context.read<AcceptOrderCubit>().confirmSms(
        code: int.parse(codeStr),
        orderId: orderId,
      );
    } finally {
      if (mounted) setState(() => _processing = false);
    }
  }

  String _resendText(TimerAuthState s) {
    // пока таймер идёт — показываем "Повторить через 00:29"
    final left = s.secondsLeft;
    if (left > 0) {
      final mm = (left ~/ 60).toString().padLeft(2, '0');
      final ss = (left % 60).toString().padLeft(2, '0');
      return 'Отправить код повторно через $mm:$ss';
    }
    return 'Отправить код повторно';
  }

  @override
  Widget build(BuildContext context) {
    final orderId = widget.order.orderId ?? 0;

    final acceptCubit = context.read<AcceptOrderCubit>();

    return StreamBuilder<AcceptOrderEffect>(
      stream: acceptCubit.effects,
      builder: (context, snap) {
        final effect = snap.data;

        if (effect != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;

            if (effect is AcceptShowError) {
              _smsController.clear();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(effect.message)),
              );
            }

            // закрытие диалога ты обычно делаешь в родителе.
            // но если хочешь — можешь и тут:
            if (effect is AcceptCloseDialog) {
              if (Navigator.of(context).canPop()) Navigator.of(context).pop();
            }
          });
        }

        return BlocBuilder<TimerAuthCubit, TimerAuthState>(
          bloc: _timerCubit,
          builder: (context, tState) {
            return BlocBuilder<AcceptOrderCubit, AcceptOrderState>(
              builder: (context, aState) {
                final isLoading = aState.status == UiStatus.loading;
                final canResend = tState.secondsLeft <= 0 && !isLoading && orderId != 0;

                return AppCardContainer(
                  backgroundColor: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  showShadow: true,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // ===== Header =====
                      AppCardContainer(
                        useMaterial: false,
                        showShadow: false,
                        showBorder: false,
                        backgroundColor: const Color(0xFFE5F3FF),
                        borderRadius: BorderRadius.circular(18),
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    'Поздравляем!\nПо вашей заявке одобрено',
                                    style: AppTypography.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Container(
                                  width: 34,
                                  height: 34,
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.check, size: 18),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              '${(widget.order.approvedAmount ?? 1000).toInt()} ₽',
                              style: AppTypography.textTheme.displaySmall?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 8),
                            if ((widget.order.activeDate ?? '').isNotEmpty)
                              Text(
                                'Вы можете принять решение до ${widget.order.activeDate}',
                                style: AppTypography.textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      Text(
                        'К выплате — ${widget.amount.toInt()} ₽',
                        style: AppTypography.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),

                      const SizedBox(height: 10),

                      // ===== Contract link =====
                      GestureDetector(
                        onTap: widget.onOpenContract,
                        child: RichText(
                          text: TextSpan(
                            style: AppTypography.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                            children: [
                              const TextSpan(text: 'Подписать с помощью СМС-кода '),
                              TextSpan(
                                text: 'Договор',
                                style: AppTypography.textTheme.bodySmall?.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w700,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // ===== SMS input =====
                      TextField(
                        controller: _smsController,
                        readOnly: isLoading,
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(4),
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: InputDecoration(
                          hintText: 'СМС-код',
                          filled: true,
                          fillColor: AppColors.secondary,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      // ===== Resend =====
                      Align(
                        alignment: Alignment.centerRight,
                        child: InkWell(
                          onTap: !canResend
                              ? null
                              : () {
                            acceptCubit.requestSms(amount: widget.amount, orderId: orderId);
                            _timerCubit.start(seconds: 30);
                          },
                          child: Text(
                            _resendText(tState),
                            style: AppTypography.textTheme.bodySmall?.copyWith(
                              color: canResend ? AppColors.primary : AppColors.greyText,
                              decoration: TextDecoration.underline,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      // ===== Docs =====
                      GestureDetector(
                        onTap: widget.onOpenDocs,
                        child: RichText(
                          text: TextSpan(
                            style: AppTypography.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                            children: [
                              const TextSpan(text: 'Подписывая договор, я соглашаюсь и подписываю '),
                              TextSpan(
                                text: 'Документы',
                                style: AppTypography.textTheme.bodySmall?.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w700,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 14),

                      // ===== Main button =====
                      SizedBox(
                        height: 56,
                        child: ElevatedButton(
                          onPressed: (isLoading || _processing || _smsController.text.length != 4)
                              ? null
                              : _submitCode,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                          ),
                          child: isLoading
                              ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                          )
                              : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Получить заём',
                                style: AppTypography.textTheme.titleSmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Text(
                                '${widget.amount.toInt()} ₽',
                                style: AppTypography.textTheme.titleSmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}