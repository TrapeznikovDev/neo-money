import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:neomoney/core/presentation/state/ui_state.dart';
import 'package:neomoney/features/home/screens/main/bloc/main_screen_state.dart';

class MainTabCubit extends Cubit<MainTabState> {
  MainTabCubit() : super (MainTabState());

  Future<void> init() async {
  }

  Future<void> refreshTransferStatus() async {
    emit(state.copyWith(status: UiStatus.loading, clearErrorMessage: true));
    try {
      // TODO: repo.checkTransferStatus()

      await Future.delayed(const Duration(milliseconds: 350));

      emit(state.copyWith(
        status: UiStatus.initial,
        isTransferInProgress: state.isTransferInProgress,
      ));
    } catch (_) {
      emit(state.copyWith(status: UiStatus.failure, errorMessage: 'Не удалось обновить статус'));
    }
  }

  void amountChanged(int value) {
    emit(state.copyWith(selectedAmount: value, clearErrorMessage: true));
  }

  Future<void> submitLoan() async {
    emit(state.copyWith(status: UiStatus.loading, clearErrorMessage: true));
    try {
      final amount = state.selectedAmount;

      // TODO: repo.submitLoan(amount)

      await Future.delayed(const Duration(milliseconds: 400));

      emit(state.copyWith(status: UiStatus.initial));
    } catch (_) {
      emit(state.copyWith(status: UiStatus.failure, errorMessage: 'Не удалось отправить заявку'));
    }
  }

  void promoChanged(String v) {
    emit(state.copyWith(promoCode: v, clearErrorMessage: true));
  }

  Future<void> applyPromo() async {
    final code = state.promoCode.trim();
    if (code.isEmpty) {
      emit(state.copyWith(status: UiStatus.failure, errorMessage: 'Введите промокод'));
      return;
    }

    emit(state.copyWith(status: UiStatus.loading, clearErrorMessage: true));
    try {
      // TODO: repo.applyPromo(code)

      await Future.delayed(const Duration(milliseconds: 350));

      emit(state.copyWith(status: UiStatus.initial));
    } catch (_) {
      emit(state.copyWith(status: UiStatus.failure, errorMessage: 'Промокод не применён'));
    }
  }
}