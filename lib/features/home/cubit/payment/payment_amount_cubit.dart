// // payment_dialog_cubit.dart
// import 'dart:async';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:neomoney/features/cards/data/models/card_model.dart';
// import 'package:neomoney/features/cards/data/repository/cards_repository.dart';
// import 'package:neomoney/features/home/model/payment_dialog_args.dart';
// import 'package:neomoney/features/home/screens/main/data/repository/orders_repository.dart';
// import 'package:neomoney/features/home/widgets/payment_dialog_effect.dart';
// import 'payment_dialog_state.dart';
// import 'payment_amount_calculator.dart';
//
// class PaymentDialogCubit extends Cubit<PaymentDialogState> {
//   final CardsRepository _cardsRepo;
//   final OrderRepository _ordersRepo;
//   final PaymentAmountCalculator _calc;
//
//   final _effects = StreamController<PaymentDialogEffect>.broadcast();
//   Stream<PaymentDialogEffect> get effects => _effects.stream;
//
//   PaymentDialogArgs? _args;
//
//   PaymentDialogCubit(
//       this._cardsRepo, {
//         PaymentAmountCalculator? calc,
//       })  : _calc = calc ?? const PaymentAmountCalculator(),
//         super(PaymentDialogState.initial(PaymentScenario.custom));
//
//   @override
//   Future<void> close() async {
//     await _effects.close();
//     return super.close();
//   }
//
//   Future<void> init(PaymentDialogArgs args) async {
//     _args = args;
//     emit(PaymentDialogState.initial(args.scenario).copyWith(status: DialogStatus.loading));
//
//     try {
//       final cards = await _cardsRepo.getCards();
//       final selected = cards.isNotEmpty ? cards.first : null;
//
//       final initial = _computeInitialAmount(args);
//       final readOnly = _isAmountReadOnly(args.scenario);
//
//       final addons = _computeAddonsTexts(args, base: _baseForAddons(args));
//
//       emit(
//         state.copyWith(
//           status: DialogStatus.idle,
//           cards: cards,
//           selectedCard: selected,
//           amount: initial,
//           amountReadOnly: readOnly,
//           insuranceOn: _insuranceDefault(args),
//           oracleOn: _oracleDefault(args),
//           vitaMedOn: _vitaMedDefault(args),
//           insuranceSumText: addons.insSumText,
//           oracleSumText: addons.orcSumText,
//           vitaMedSumText: addons.vitaSumText,
//         ),
//       );
//
//       // Для FULL_PAY грузим доки (если нужно)
//       if (args.scenario == PaymentScenario.fullPay) {
//         await _loadDocsForFullPay();
//         // пересчёт суммы по включенным допам (если default on)
//         _recalculateAmountForFullPay();
//       }
//     } catch (e) {
//       emit(state.copyWith(status: DialogStatus.error, error: e.toString()));
//       _effects.add(PaymentShowError(e.toString()));
//     }
//   }
//
//   bool _isAmountReadOnly(PaymentScenario scenario) {
//     return scenario == PaymentScenario.prolongation ||
//         scenario == PaymentScenario.fullPay ||
//         scenario == PaymentScenario.chdp;
//   }
//
//   double _computeInitialAmount(PaymentDialogArgs args) {
//     switch (args.scenario) {
//       case PaymentScenario.prolongation:
//         return _calc.clampAmount(args.baseAmount ?? 0);
//       case PaymentScenario.discount:
//         return _calc.clampAmount(_orders.getDiscountAmount(args.orderIndex) ?? args.baseAmount ?? 0);
//       case PaymentScenario.chdp:
//         return _calc.clampAmount(args.baseAmount ?? 0);
//       case PaymentScenario.fullPay:
//         final base = _orders.getTodayAmount(args.orderIndex) ?? args.baseAmount ?? 0;
//         return _calc.clampAmount(base);
//       case PaymentScenario.custom:
//         return _calc.clampAmount(args.baseAmount ?? 0);
//     }
//   }
//
//   double _baseForAddons(PaymentDialogArgs args) {
//     return _orders.getTodayAmount(args.orderIndex) ?? args.baseAmount ?? 0;
//   }
//
//   bool _insuranceDefault(PaymentDialogArgs args) {
//     // у тебя было checked=true по умолчанию
//     return args.scenario == PaymentScenario.fullPay && _orders.getFkInsurancePercent(args.orderIndex) != 0;
//   }
//
//   bool _oracleDefault(PaymentDialogArgs args) {
//     return args.scenario == PaymentScenario.fullPay && _orders.getFkOraclePercent(args.orderIndex) != 0;
//   }
//
//   bool _vitaMedDefault(PaymentDialogArgs args) {
//     return args.scenario == PaymentScenario.fullPay && _orders.getFullPayVitaMedEnabled(args.orderIndex);
//   }
//
//   void setAmountFromDigits(String digitsOnly) {
//     final a = _args;
//     if (a == null) return;
//     if (state.amountReadOnly) return;
//
//     final parsed = double.tryParse(digitsOnly);
//     emit(state.copyWith(amount: _calc.clampAmount(parsed ?? 0)));
//   }
//
//   void selectCard(CardModel card) {
//     emit(state.copyWith(selectedCard: card));
//   }
//
//   void toggleInsurance(bool value) {
//     emit(state.copyWith(insuranceOn: value));
//     if ((_args?.scenario) == PaymentScenario.fullPay) {
//       _recalculateAmountForFullPay();
//     }
//   }
//
//   void toggleOracle(bool value) {
//     emit(state.copyWith(oracleOn: value));
//     if ((_args?.scenario) == PaymentScenario.fullPay) {
//       _recalculateAmountForFullPay();
//     }
//   }
//
//   void toggleVitaMed(bool value) {
//     emit(state.copyWith(vitaMedOn: value));
//     if ((_args?.scenario) == PaymentScenario.fullPay) {
//       _recalculateAmountForFullPay();
//     }
//   }
//
//   Future<void> payB2P() => _pay(PaymentType.b2p);
//   Future<void> paySBP() => _pay(PaymentType.sbp);
//
//   Future<void> _pay(PaymentType type) async {
//     final a = _args;
//     if (a == null) return;
//
//     if (type == PaymentType.b2p) {
//       emit(state.copyWith(payB2pLoading: true));
//     } else {
//       emit(state.copyWith(paySbpLoading: true));
//     }
//
//     String _err(Object e) => e.toString().replaceFirst('Exception: ', '');
//
//     try {
//       final amount = state.amount;
//
//       final isSmsFlow =
//           a.scenario == PaymentScenario.prolongation || a.scenario == PaymentScenario.chdp;
//
//       if (isSmsFlow) {
//         await _paymentsRepo.sendSmsPayment(amount: amount);
//
//         _effects.add(
//           PaymentOpenSmsDialog(
//             type: type,
//             amount: amount,
//             selectedCardId: state.selectedCard?.id,
//             prolPeriod: a.prolPeriod,
//             multipolis: a.multipolis,
//             tvMedical: a.tvMedical,
//             sendLoanAfterClosing: a.sendLoanAfterClosing,
//             chdp: a.chdp,
//             orderIndex: a.orderIndex,
//           ),
//         );
//         _effects.add(const PaymentCloseDialog());
//         return;
//       }
//
//       final url = await _ordersRepo.getPaymentUrl(
//         cardId: state.selectedCard?.id,
//         amount: amount,
//         prolPeriod: a.prolPeriod,
//         orderNumber: _orders.getOrderNumber(a.orderIndex),
//         smsCode: null,
//         prolongation: '0',
//         sendLoanAfterClosing: a.sendLoanAfterClosing,
//         multipolis: a.multipolis,
//         tvMedical: a.tvMedical,
//         type: type == PaymentType.b2p ? 'b2p' : 'sbp',
//         action: a.action,
//         chdp: a.chdp,
//       );
//
//       _effects.add(PaymentOpenWebView(url: url, type: type));
//     } catch (e) {
//       final msg = _err(e);
//       _effects.add(PaymentShowError(msg));
//       emit(state.copyWith(status: DialogStatus.error, error: msg));
//     } finally {
//       if (type == PaymentType.b2p) {
//         emit(state.copyWith(payB2pLoading: false));
//       } else {
//         emit(state.copyWith(paySbpLoading: false));
//       }
//     }
//   }
//
//   Future<void> onWebViewClosed() async {
//     try {
//       await _ordersRefresher.refreshOrders();
//     } catch (_) {
//       // можно игнорить или показать
//     }
//   }
//
//   // ------------------------
//   // FULL PAY doc + recalcs
//   // ------------------------
//
//   Future<void> _loadDocsForFullPay() async {
//     try {
//       final docs = await _ordersRepo.getDocs(type: 'FULL_PAY');
//
//       String? insUrl;
//       String? orcUrl;
//
//       for (final d in docs) {
//         if (insUrl == null && d.text.contains('Страхование')) insUrl = d.link;
//         if (orcUrl == null && d.text.contains('Оракул')) orcUrl = d.link;
//       }
//
//       emit(state.copyWith(insuranceDocUrl: insUrl, oracleDocUrl: orcUrl));
//     } catch (e) {
//       // доки не критичны, но можно подсветить
//     }
//   }
//
//   void _recalculateAmountForFullPay() {
//     final a = _args;
//     if (a == null) return;
//
//     final base = _orders.getTodayAmount(a.orderIndex) ?? 0;
//
//     final insPercent = _orders.getFkInsurancePercent(a.orderIndex);
//     final orcPercent = _orders.getFkOraclePercent(a.orderIndex);
//
//     final insAddon = _calc.computeAddonByPercent(base: base, percent: insPercent, enabled: state.insuranceOn);
//     final orcAddon = _calc.computeAddonByPercent(base: base, percent: orcPercent, enabled: state.oracleOn);
//
//     double total = base + insAddon + orcAddon;
//
//     if (state.vitaMedOn && _orders.getFullPayVitaMedEnabled(a.orderIndex)) {
//       total += _orders.getFullPayVitaMedAmount(a.orderIndex);
//     }
//
//     // Если oracleEnabled и есть фикс oracleAmount на заказе
//     if (_orders.getOracleEnabled(a.orderIndex)) {
//       total += _orders.getOracleAmount(a.orderIndex);
//     }
//
//     emit(state.copyWith(amount: _calc.clampAmount(total)));
//   }
//
//   _AddonTexts _computeAddonsTexts(PaymentDialogArgs args, {required double base}) {
//     // показываем суммы допов в UI
//     final insPercent = _orders.getFkInsurancePercent(args.orderIndex);
//     final orcPercent = _orders.getFkOraclePercent(args.orderIndex);
//
//     final insAddon = _calc.computeAddonByPercent(base: base, percent: insPercent, enabled: true);
//     final orcAddon = _calc.computeAddonByPercent(base: base, percent: orcPercent, enabled: true);
//
//     final vita = _orders.getFullPayVitaMedAmount(args.orderIndex);
//
//     return _AddonTexts(
//       insSumText: insAddon > 0 ? formatNumber(insAddon) : '',
//       orcSumText: orcAddon > 0 ? formatNumber(orcAddon) : '',
//       vitaSumText: vita > 0 ? formatNumber(vita) : '',
//     );
//   }
// }
//
// class _AddonTexts {
//   final String insSumText;
//   final String orcSumText;
//   final String vitaSumText;
//   const _AddonTexts({
//     required this.insSumText,
//     required this.orcSumText,
//     required this.vitaSumText,
//   });
// }