// payment_dialog_args.dart
enum PaymentScenario { prolongation, fullPay, discount, chdp, custom }
enum PaymentType { b2p, sbp }

class PaymentDialogArgs {
  final int organizationId;
  final int orderIndex;

  final PaymentScenario scenario;

  final double? baseAmount;

  final int? prolPeriod;
  final bool sendLoanAfterClosing;

  /// Фичи
  final bool multipolis;
  final bool tvMedical;
  final bool sbpReccurentsEnabled;

  final int? chdp;

  final int fkInsurancePercent;
  final int fkOraclePercent;

  final bool vitaMedEnabled;
  final double vitaMedAmount;

  final bool oracleEnabled;
  final double oracleAmount;

  final bool insuranceEnabled;
  final double insuranceAmount;

  const PaymentDialogArgs({
    required this.organizationId,
    required this.orderIndex,
    required this.scenario,
    this.baseAmount,
    this.prolPeriod,
    this.sendLoanAfterClosing = false,
    this.multipolis = false,
    this.tvMedical = false,
    this.sbpReccurentsEnabled = false,
    this.chdp,
    this.fkInsurancePercent = 0,
    this.fkOraclePercent = 0,
    this.vitaMedEnabled = false,
    this.vitaMedAmount = 0,
    this.oracleEnabled = false,
    this.oracleAmount = 0,
    this.insuranceEnabled = false,
    this.insuranceAmount = 0,
  });
}