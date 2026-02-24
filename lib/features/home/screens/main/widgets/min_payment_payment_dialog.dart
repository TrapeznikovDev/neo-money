// features/home/screens/main/widgets/payment_dialog.dart
// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:neomoney/app/di.dart';
import 'package:neomoney/core/presentation/state/ui_state.dart';
import 'package:neomoney/core/ui/theme/app_colors.dart';
import 'package:neomoney/core/ui/theme/app_text_styles.dart';
import 'package:neomoney/features/cards/data/cubit/cards_cubit.dart';
import 'package:neomoney/features/cards/data/cubit/cards_state.dart';
import 'package:neomoney/features/cards/data/models/card_model.dart';
import 'package:neomoney/features/home/cubit/order_url/order_url_cubit.dart';
import 'package:neomoney/features/home/cubit/order_url/order_url_state.dart';
import 'package:neomoney/features/home/screens/main/data/models/order_model.dart';
import 'package:neomoney/features/home/screens/main/widgets/app_web_view.dart';

enum PaymentMethod { card, sbp }

class PaymentDialog extends StatefulWidget {
  final OrderModel order;
  final double amount;

  /// 'MIN_PAY' | 'FULL_PAY' | ... (как договоритесь с бэком)
  final String action;

  final VoidCallback onAfterSuccessRefresh;

  const PaymentDialog({
    super.key,
    required this.order,
    required this.amount,
    required this.action,
    required this.onAfterSuccessRefresh,
  });

  static Future<void> show(
      BuildContext context, {
        required OrderModel order,
        required double amount,
        required String action,
        required VoidCallback onAfterSuccessRefresh,
      }) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => PaymentDialog(
        order: order,
        amount: amount,
        action: action,
        onAfterSuccessRefresh: onAfterSuccessRefresh,
      ),
    );
  }

  @override
  State<PaymentDialog> createState() => _PaymentDialogState();
}

class _PaymentDialogState extends State<PaymentDialog> {
  PaymentMethod _method = PaymentMethod.card;

  late final CardsCubit _cardsCubit;
  late final OrderUrlCubit _orderUrlCubit;

  CardModel? _selectedCard;

  @override
  void initState() {
    super.initState();
    _cardsCubit = getIt<CardsCubit>()..load();
    _orderUrlCubit = getIt<OrderUrlCubit>();
  }

  @override
  void dispose() {
    // если твой OrderUrlCubit singleton — не закрываем.
    // если factory — можно закрыть:
    // _orderUrlCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final amountText = _formatRub(widget.amount);

    return MultiBlocProvider(
      providers: [
        BlocProvider<CardsCubit>.value(value: _cardsCubit),
        BlocProvider<OrderUrlCubit>.value(value: _orderUrlCubit),
      ],
      child: Dialog(
        insetPadding: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: BlocConsumer<OrderUrlCubit, OrderUrlState>(
            listenWhen: (p, n) =>
            p.status != n.status ||
                p.url != n.url ||
                p.errorMessage != n.errorMessage,
            listener: (context, s) async {
              if (s.status == UiStatus.failure &&
                  (s.errorMessage?.isNotEmpty ?? false)) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(s.errorMessage!)),
                );
              }

              if (s.status == UiStatus.success && (s.url?.isNotEmpty ?? false)) {
                // Открываем WebView. Он вернет true/false (успех/ошибка).
                final ok = await Navigator.of(context).push<bool>(
                  MaterialPageRoute(
                    builder: (_) => AppPaymentWebViewScreen(url: s.url!),
                  ),
                );

                // Даже если ok == null — можно просто refresh, как в boostra.
                // Но обычно удобнее refresh только при успехе:
                if (ok == true) {
                  widget.onAfterSuccessRefresh();
                } else {
                  // по желанию:
                  // widget.onAfterSuccessRefresh();
                }

                if (context.mounted) Navigator.of(context).pop();
              }
            },
            builder: (context, urlState) {
              final isUrlLoading = urlState.status == UiStatus.loading;

              return BlocBuilder<CardsCubit, CardsState>(
                builder: (context, cs) {
                  final cardsLoading = cs.status == UiStatus.loading;
                  final cards = cs.cards;

                  // дефолтный выбор карты
                  if (_selectedCard == null && cards.isNotEmpty) {
                    _selectedCard = cards.first;
                  }

                  final loading = isUrlLoading || cardsLoading;

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Сумма к оплате',
                        style: AppTypography.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppColors.secondary,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(
                          '$amountText ₽',
                          style: AppTypography.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            child: _MethodChip(
                              title: 'Карта',
                              selected: _method == PaymentMethod.card,
                              onTap: loading
                                  ? null
                                  : () =>
                                  setState(() => _method = PaymentMethod.card),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _MethodChip(
                              title: 'СБП',
                              selected: _method == PaymentMethod.sbp,
                              onTap: loading
                                  ? null
                                  : () =>
                                  setState(() => _method = PaymentMethod.sbp),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      if (cardsLoading) ...[
                        const Center(child: CircularProgressIndicator()),
                        const SizedBox(height: 12),
                      ] else if (cards.isEmpty) ...[
                        Text(
                          'Нет привязанных карт',
                          style: AppTypography.textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                      ] else ...[
                        Text(
                          'Выберите карту',
                          style: AppTypography.textTheme.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 8),
                        _CardDropdown(
                          cards: cards,
                          value: cards.contains(_selectedCard)
                              ? _selectedCard
                              : cards.first,
                          onChanged: loading
                              ? null
                              : (c) => setState(() => _selectedCard = c),
                        ),
                        const SizedBox(height: 16),
                      ],

                      SizedBox(
                        height: 52,
                        child: ElevatedButton(
                          onPressed: loading ? null : _onPayPressed,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                            elevation: 0,
                          ),
                          child: loading
                              ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                              : Text(
                            _method == PaymentMethod.card
                                ? 'Оплатить картой'
                                : 'Оплатить через СБП',
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      TextButton(
                        onPressed: loading ? null : () => Navigator.of(context).pop(),
                        child: Text(
                          'Отмена',
                          style: AppTypography.textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _onPayPressed() async {
    final orderNumber = widget.order.number ?? '';
    if (orderNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('order.number отсутствует')),
      );
      return;
    }

    if (widget.amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Некорректная сумма')),
      );
      return;
    }

    // Для b2p обычно нужен cardId. Для sbp — зависит от бэка; в boostra cardId тоже отправляли.
    final cardId = _selectedCard?.id;
    if (_method == PaymentMethod.card && cardId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Карта не выбрана')),
      );
      return;
    }

    await context.read<OrderUrlCubit>().loadUrl(
      cardId: cardId,
      amount: widget.amount,
      prolPeriod: null, // для min/full обычно null
      prolongation: '0',
      orderNumber: orderNumber,
      type: _method == PaymentMethod.card ? 'b2p' : 'sbp',
      action: widget.action, // <-- ВОТ ТУТ различаем MIN_PAY / FULL_PAY
      // multipolis/tvMedical/sendLoanAfterClosing/chdp — если надо, прокинь параметрами
    );
  }

  String _formatRub(double v) {
    final i = v.round();
    return i.toString();
  }
}

class _MethodChip extends StatelessWidget {
  final String title;
  final bool selected;
  final VoidCallback? onTap;

  const _MethodChip({
    required this.title,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: selected ? AppColors.primary.withOpacity(0.10) : AppColors.secondary,
          border: Border.all(color: selected ? AppColors.primary : AppColors.border),
        ),
        child: Center(
          child: Text(
            title,
            style: AppTypography.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: selected ? AppColors.primary : AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}

class _CardDropdown extends StatelessWidget {
  final List<CardModel> cards;
  final CardModel? value;
  final ValueChanged<CardModel?>? onChanged;

  const _CardDropdown({
    required this.cards,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(14),
        color: AppColors.scaffold,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: DropdownButton<CardModel>(
        isExpanded: true,
        value: value,
        underline: const SizedBox.shrink(),
        borderRadius: BorderRadius.circular(14),
        items: cards.map((c) {
          return DropdownMenuItem<CardModel>(
            value: c,
            child: Text(
              _cardTitle(c),
              style: AppTypography.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  String _cardTitle(CardModel c) {
    // Подстрой под свою модель (maskedPan/last4/cardNumber и т.д.)
    // Ниже — безопасный вариант:
    final s = (c.toString());
    return s;
  }
}