import 'package:neomoney/core/presentation/state/ui_state.dart';
import 'package:neomoney/features/registration/data/models/bank_model.dart';

class RegBankSelectionState implements UiState {
  @override
  final UiStatus status;
  @override
  final String? errorMessage;

  final bool buttonLoading;

  final List<BankModel> banks;
  final BankModel? selectedBank;
  final String selectedMethod;

  const RegBankSelectionState({
    this.status = UiStatus.initial,
    this.errorMessage,
    this.buttonLoading = false,
    this.banks = const [],
    this.selectedBank,
    this.selectedMethod = 'Система быстрых платежей',
  });

  bool get isLoading => status == UiStatus.loading;

  RegBankSelectionState copyWith({
    UiStatus? status,

    String? errorMessage,
    bool clearErrorMessage = false,

    bool? buttonLoading,
    List<BankModel>? banks,
    BankModel? selectedBank,
    String? selectedMethod,
  }) {
    return RegBankSelectionState(
      status: status ?? this.status,
      errorMessage: clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
      buttonLoading: buttonLoading ?? this.buttonLoading,
      banks: banks ?? this.banks,
      selectedBank: selectedBank ?? this.selectedBank,
      selectedMethod: selectedMethod ?? this.selectedMethod,
    );
  }

  static const initial = RegBankSelectionState();
}