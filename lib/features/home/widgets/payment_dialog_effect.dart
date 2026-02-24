// payment_dialog_effect.dart

import 'package:neomoney/features/home/model/payment_dialog_args.dart';

abstract class PaymentDialogEffect {
  const PaymentDialogEffect();
}

class PaymentOpenWebView extends PaymentDialogEffect {
  final String url;
  final PaymentType type;
  const PaymentOpenWebView({required this.url, required this.type});
}

class PaymentOpenSmsDialog extends PaymentDialogEffect {
  final PaymentType type;
  final double amount;
  final int? selectedCardId;
  final int? prolPeriod;
  final bool multipolis;
  final bool tvMedical;
  final bool sendLoanAfterClosing;
  final int? chdp;
  final int orderIndex;

  const PaymentOpenSmsDialog({
    required this.type,
    required this.amount,
    required this.selectedCardId,
    required this.prolPeriod,
    required this.multipolis,
    required this.tvMedical,
    required this.sendLoanAfterClosing,
    required this.chdp,
    required this.orderIndex,
  });
}

class PaymentCloseDialog extends PaymentDialogEffect {
  const PaymentCloseDialog();
}

class PaymentShowError extends PaymentDialogEffect {
  final String message;
  const PaymentShowError(this.message);
}