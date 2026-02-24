// payment_dialog_state.dart
import 'package:equatable/equatable.dart';
import 'package:neomoney/features/cards/data/models/card_model.dart';
import 'package:neomoney/features/home/model/payment_dialog_args.dart';

enum DialogStatus { idle, loading, error }

class PaymentDialogState extends Equatable {
  final DialogStatus status;
  final String? error;

  final List<CardModel> cards;
  final CardModel? selectedCard;

  /// сумма — единственный source of truth
  final double amount;
  final bool amountReadOnly;

  /// допы
  final bool insuranceOn;
  final bool oracleOn;
  final bool vitaMedOn;

  final String insuranceSumText;
  final String oracleSumText;
  final String vitaMedSumText;

  /// ссылки на доки (если нужны)
  final String? insuranceDocUrl;
  final String? oracleDocUrl;

  final bool payB2pLoading;
  final bool paySbpLoading;

  final PaymentScenario scenario;

  const PaymentDialogState({
    required this.status,
    required this.cards,
    required this.amount,
    required this.amountReadOnly,
    required this.insuranceOn,
    required this.oracleOn,
    required this.vitaMedOn,
    required this.insuranceSumText,
    required this.oracleSumText,
    required this.vitaMedSumText,
    required this.payB2pLoading,
    required this.paySbpLoading,
    required this.scenario,
    this.error,
    this.selectedCard,
    this.insuranceDocUrl,
    this.oracleDocUrl,
  });

  factory PaymentDialogState.initial(PaymentScenario scenario) {
    return PaymentDialogState(
      status: DialogStatus.idle,
      cards: const [],
      amount: 0,
      amountReadOnly: false,
      insuranceOn: false,
      oracleOn: false,
      vitaMedOn: false,
      insuranceSumText: '',
      oracleSumText: '',
      vitaMedSumText: '',
      payB2pLoading: false,
      paySbpLoading: false,
      scenario: scenario,
    );
  }

  PaymentDialogState copyWith({
    DialogStatus? status,
    String? error,
    List<CardModel>? cards,
    CardModel? selectedCard,
    double? amount,
    bool? amountReadOnly,
    bool? insuranceOn,
    bool? oracleOn,
    bool? vitaMedOn,
    String? insuranceSumText,
    String? oracleSumText,
    String? vitaMedSumText,
    String? insuranceDocUrl,
    String? oracleDocUrl,
    bool? payB2pLoading,
    bool? paySbpLoading,
  }) {
    return PaymentDialogState(
      status: status ?? this.status,
      error: error,
      cards: cards ?? this.cards,
      selectedCard: selectedCard ?? this.selectedCard,
      amount: amount ?? this.amount,
      amountReadOnly: amountReadOnly ?? this.amountReadOnly,
      insuranceOn: insuranceOn ?? this.insuranceOn,
      oracleOn: oracleOn ?? this.oracleOn,
      vitaMedOn: vitaMedOn ?? this.vitaMedOn,
      insuranceSumText: insuranceSumText ?? this.insuranceSumText,
      oracleSumText: oracleSumText ?? this.oracleSumText,
      vitaMedSumText: vitaMedSumText ?? this.vitaMedSumText,
      insuranceDocUrl: insuranceDocUrl ?? this.insuranceDocUrl,
      oracleDocUrl: oracleDocUrl ?? this.oracleDocUrl,
      payB2pLoading: payB2pLoading ?? this.payB2pLoading,
      paySbpLoading: paySbpLoading ?? this.paySbpLoading,
      scenario: scenario,
    );
  }

  @override
  List<Object?> get props => [
    status,
    error,
    cards,
    selectedCard,
    amount,
    amountReadOnly,
    insuranceOn,
    oracleOn,
    vitaMedOn,
    insuranceSumText,
    oracleSumText,
    vitaMedSumText,
    insuranceDocUrl,
    oracleDocUrl,
    payB2pLoading,
    paySbpLoading,
    scenario,
  ];
}