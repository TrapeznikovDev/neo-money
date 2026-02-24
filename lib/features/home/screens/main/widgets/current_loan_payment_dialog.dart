// // current_loan_payment_dialog.dart
// import 'dart:async';
//
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:neomoney/features/home/cubit/payment/payment_amount_cubit.dart';
// import 'package:neomoney/features/home/cubit/payment/payment_dialog_state.dart';
// import 'package:neomoney/features/home/model/payment_dialog_args.dart';
// import 'package:neomoney/features/home/widgets/payment_dialog_effect.dart';
//
// class CurrentLoanPaymentDialog extends StatefulWidget {
//   final PaymentDialogArgs args;
//   const CurrentLoanPaymentDialog({super.key, required this.args});
//
//   @override
//   State<CurrentLoanPaymentDialog> createState() => _CurrentLoanPaymentDialogState();
// }
//
// class _CurrentLoanPaymentDialogState extends State<CurrentLoanPaymentDialog> {
//   late final TextEditingController _amountCtrl;
//   StreamSubscription<PaymentDialogEffect>? _sub;
//
//   @override
//   void initState() {
//     super.initState();
//     _amountCtrl = TextEditingController();
//   }
//
//   @override
//   void dispose() {
//     _sub?.cancel();
//     _amountCtrl.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider<PaymentDialogCubit>(
//       create: (_) {
//         final cubit = context.read<PaymentDialogCubit>(); // или getIt<PaymentDialogCubit>()
//         // подписка 1 раз
//         _sub?.cancel();
//         _sub = cubit.effects.listen((effect) {
//           if (!mounted) return;
//           _handleEffect(context, effect);
//         });
//         cubit.init(widget.args);
//         return cubit;
//       },
//       child: BlocConsumer<PaymentDialogCubit, PaymentDialogState>(
//         listener: (context, s) {
//           final formatted = s.amount == 0 ? '' : formatNumber(s.amount);
//           if (_amountCtrl.text != formatted) {
//             _amountCtrl.value = TextEditingValue(
//               text: formatted,
//               selection: TextSelection.collapsed(offset: formatted.length),
//             );
//           }
//         },
//         builder: (context, s) {
//           final cubit = context.read<PaymentDialogCubit>();
//
//           return Dialog(
//             insetPadding: const EdgeInsets.all(25),
//             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//             child: Container(
//               padding: const EdgeInsets.all(15),
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(20),
//                 color: Colors.white,
//               ),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 crossAxisAlignment: CrossAxisAlignment.stretch,
//                 children: [
//                   Text(
//                     'Сумма к оплате',
//                     style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                       fontWeight: FontWeight.w700,
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//
//                   RegNfTextField(
//                     readOnly: s.amountReadOnly,
//                     hintText: '1000 ₽',
//                     inputFormatters: [FilteringTextInputFormatter.digitsOnly],
//                     suffix: '₽',
//                     controller: _amountCtrl,
//                     color: const Color(0xFFDADADA),
//                     containerColor: const Color(0xFFDADADA),
//                     onChanged: (v) {
//                       final digits = v.replaceAll(RegExp(r'\D'), '');
//                       cubit.setAmountFromDigits(digits);
//                     },
//                   ),
//
//                   const SizedBox(height: 16),
//
//                   if (widget.args.scenario == PaymentScenario.fullPay) ...[
//                     if (s.insuranceSumText.isNotEmpty)
//                       CheckboxNfTile(
//                         titleText: 'Страхование ',
//                         sum: s.insuranceSumText,
//                         checked: s.insuranceOn,
//                         linkText: s.insuranceDocUrl,
//                         onChanged: (value) => cubit.toggleInsurance(value ?? false),
//                       ),
//                     if (s.oracleSumText.isNotEmpty)
//                       CheckboxNfTile(
//                         titleText: 'Звездный Оракул ',
//                         sum: s.oracleSumText,
//                         checked: s.oracleOn,
//                         linkText: s.oracleDocUrl,
//                         onChanged: (value) => cubit.toggleOracle(value ?? false),
//                       ),
//                   ],
//
//                   const SizedBox(height: 16),
//
//                   if (s.cards.isNotEmpty) ...[
//                     Text(
//                       'Выберите карту для оплаты',
//                       style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                         fontWeight: FontWeight.w700,
//                       ),
//                     ),
//                     const SizedBox(height: 12),
//                     Container(
//                       decoration: BoxDecoration(
//                         border: Border.all(color: const Color(0xFFDADADA)),
//                         borderRadius: BorderRadius.circular(15),
//                       ),
//                       padding: const EdgeInsets.symmetric(horizontal: 10),
//                       child: DropdownButton(
//                         isExpanded: true,
//                         underline: const SizedBox(),
//                         borderRadius: BorderRadius.circular(20),
//                         value: s.cards.contains(s.selectedCard) ? s.selectedCard : s.cards.first,
//                         items: s.cards.map((e) {
//                           return DropdownMenuItem(
//                             value: e,
//                             child: Text(e.cardNumber),
//                           );
//                         }).toList(),
//                         onChanged: (value) {
//                           if (value != null) cubit.selectCard(value);
//                         },
//                       ),
//                     ),
//                   ],
//
//                   const Gap(16),
//
//                   MainButtonNfOrange(
//                     state: s.payB2pLoading,
//                     wid: const CircularProgressIndicator(color: Colors.white),
//                     hPadding: 0,
//                     vPadding: 0,
//                     text: 'Оплатить',
//                     onPressed: s.payB2pLoading ? null : cubit.payB2P,
//                   ),
//
//                   const Gap(10),
//
//                   SbpNfButton(
//                     state: s.paySbpLoading,
//                     wid: const CircularProgressIndicator(color: Colors.white),
//                     text: '',
//                     onPressed: s.paySbpLoading ? null : cubit.paySBP,
//                   ),
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
//
//   Future<void> _handleEffect(BuildContext context, PaymentDialogEffect effect) async {
//     final cubit = context.read<PaymentDialogCubit>();
//
//     if (effect is PaymentShowError) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text(effect.message)),
//       );
//       return;
//     }
//
//     if (effect is PaymentCloseDialog) {
//       if (Navigator.of(context).canPop()) Navigator.of(context).pop();
//       return;
//     }
//
//     if (effect is PaymentOpenWebView) {
//       await Navigator.of(context).push(
//         MaterialPageRoute(builder: (_) => WebViewNfPage(url: effect.url)),
//       );
//       await cubit.onWebViewClosed();
//       return;
//     }
//
//     if (effect is PaymentOpenSmsDialog) {
//       showDialog(
//         context: context,
//         builder: (_) => CurrentLoanSmsNfDialog(
//           index: effect.orderIndex,
//           prolPeriod: effect.prolPeriod,
//           multipolis: effect.multipolis,
//           tvMedical: effect.tvMedical,
//           selectedCardId: effect.selectedCardId,
//           sendLoanAfterClosing: effect.sendLoanAfterClosing,
//           type: effect.type == PaymentType.b2p ? 'b2p' : 'sbp',
//           amount: effect.amount,
//         ),
//       );
//       return;
//     }
//   }
// }