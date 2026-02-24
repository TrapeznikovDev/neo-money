class PaymentItemModel {
  final DateTime paymentFromDate;
  final DateTime paymentDate;
  final double percentSum;
  final double loanBodySum;
  final double paymentSum;
  final double loanBalance;

  PaymentItemModel({
    required this.paymentFromDate,
    required this.paymentDate,
    required this.percentSum,
    required this.loanBodySum,
    required this.paymentSum,
    required this.loanBalance,
  });

  factory PaymentItemModel.fromJson(Map<String, dynamic> json) {
    return PaymentItemModel(
      paymentFromDate: DateTime.parse(json['payment_from_date']),
      paymentDate: DateTime.parse(json['payment_date']),
      percentSum: (json['percent_sum'] as num).toDouble(),
      loanBodySum: (json['loan_body_sum'] as num).toDouble(),
      paymentSum: (json['payment_sum'] as num).toDouble(),
      loanBalance: (json['loan_balance'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'payment_from_date': paymentFromDate.toIso8601String(),
      'payment_date': paymentDate.toIso8601String(),
      'percent_sum': percentSum,
      'loan_body_sum': loanBodySum,
      'payment_sum': paymentSum,
      'loan_balance': loanBalance,
    };
  }
}
