class LoanCalcResult {
  final int fullAmountToBePaid;
  final double percent;

  const LoanCalcResult({
    required this.fullAmountToBePaid,
    required this.percent,
  });

  factory LoanCalcResult.fromJson(Map<String, dynamic> json) {
    return LoanCalcResult(
      fullAmountToBePaid: (json['fullAmountToBePaid'] ?? json['full_amount_to_be_paid'] ?? 0) as int,
      percent: (json['percent'] as num?)?.toDouble() ?? 0.0,
    );
  }
}