import 'package:neomoney/core/presentation/state/ui_state.dart';

class MainTabState extends UiState {
  final UiStatus _status;
  final String? _errorMessage;

  final String userName;

  final bool isTransferInProgress;

  final int approvedAmountRub;
  final String decisionUntilText;

  final int minAmount;
  final int maxAmount;
  final int selectedAmount;

  final String promoCode;

   MainTabState({
    UiStatus status = UiStatus.initial,
    String? errorMessage,
    this.userName = 'Имя Отчество',
    this.isTransferInProgress = true,
    this.approvedAmountRub = 30000,
    this.decisionUntilText = 'Вы можете принять решение до 00.00.00',
    this.minAmount = 22000,
    this.maxAmount = 30000,
    this.selectedAmount = 30000,
    this.promoCode = 'PERVIY',
  })  : _status = status,
        _errorMessage = errorMessage;

  MainTabState copyWith({
    UiStatus? status,
    String? errorMessage,
    bool clearErrorMessage = false,

    String? userName,
    bool? isTransferInProgress,
    int? approvedAmountRub,
    String? decisionUntilText,

    int? minAmount,
    int? maxAmount,
    int? selectedAmount,

    String? promoCode,
  }) {
    return MainTabState(
      status: status ?? _status,
      errorMessage: clearErrorMessage ? null : (errorMessage ?? _errorMessage),

      userName: userName ?? this.userName,
      isTransferInProgress: isTransferInProgress ?? this.isTransferInProgress,
      approvedAmountRub: approvedAmountRub ?? this.approvedAmountRub,
      decisionUntilText: decisionUntilText ?? this.decisionUntilText,

      minAmount: minAmount ?? this.minAmount,
      maxAmount: maxAmount ?? this.maxAmount,
      selectedAmount: selectedAmount ?? this.selectedAmount,

      promoCode: promoCode ?? this.promoCode,
    );
  }

  @override
  UiStatus get status => _status;

  @override
  String? get errorMessage => _errorMessage;
}