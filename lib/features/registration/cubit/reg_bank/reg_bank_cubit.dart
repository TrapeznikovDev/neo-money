import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:neomoney/core/presentation/state/ui_state.dart';
import 'package:neomoney/features/registration/cubit/reg_bank/reg_bank_state.dart';
import 'package:neomoney/features/registration/data/models/bank_model.dart';
import 'package:neomoney/features/registration/data/domain/registration_repository.dart';

class RegBankSelectionCubit extends Cubit<RegBankSelectionState> {
  final RegistrationRepository _repo;

  RegBankSelectionCubit(this._repo) : super(RegBankSelectionState.initial) {
    getSBPBankList();
  }

  Future<void> getSBPBankList() async {
    emit(state.copyWith(status: UiStatus.loading, clearErrorMessage: true));
    try {
      final banks = await _repo.getSBPBankList();
      emit(state.copyWith(status: UiStatus.initial, banks: banks));
    } catch (e) {
      emit(state.copyWith(
        status: UiStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  void onChangedBank(BankModel? b) => emit(state.copyWith(selectedBank: b));
  void onChangedMethod(String m) => emit(state.copyWith(selectedMethod: m));

  Future<void> selectSBPBank() async {
    final bank = state.selectedBank;
    if (bank == null) {
      emit(state.copyWith(status: UiStatus.failure, errorMessage: 'Выберите банк'));
      return;
    }

    emit(state.copyWith(buttonLoading: true, clearErrorMessage: true));
    try {
      await _repo.selectSBPBank(bankId: bank.id, orderId: null);
      emit(state.copyWith(buttonLoading: false));

      // важно: после выбора банка — на home (как в старом)
      // навигация обычно в UI-слое; но можно вернуть флаг через state.
      // Я оставлю проще: вызови навигацию в экране по успеху через статус/side-effect.
      emit(state.copyWith(status: UiStatus.initial));
    } catch (e) {
      emit(state.copyWith(
        buttonLoading: false,
        status: UiStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }
}