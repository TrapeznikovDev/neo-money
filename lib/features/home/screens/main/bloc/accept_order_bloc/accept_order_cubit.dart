import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:neomoney/core/presentation/state/ui_state.dart';
import 'package:neomoney/features/home/screens/main/bloc/accept_order_bloc/accept_order_effect.dart';
import 'package:neomoney/features/home/screens/main/bloc/accept_order_bloc/accept_order_state.dart';
import 'package:neomoney/features/home/screens/main/data/repository/orders_repository.dart';

class AcceptOrderCubit extends Cubit<AcceptOrderState> {
  final OrderRepository _repo;

  final _effects = StreamController<AcceptOrderEffect>.broadcast();

  Stream<AcceptOrderEffect> get effects => _effects.stream;

  Timer? _checkLoanTimer;

  AcceptOrderCubit(this._repo) : super(const AcceptOrderState());

  @override
  Future<void> close() async {
    _checkLoanTimer?.cancel();
    await _effects.close();
    return super.close();
  }

  /// 1) отправить SMS
  Future<void> requestSms({required double amount, required int orderId}) async {
    emit(state.copyWith(status: UiStatus.loading, errorMessage: null, success: false));

    try {
      final err = await _repo.sendSms(amount: amount, orderId: orderId);

      if (err.isNotEmpty) {
        emit(state.copyWith(status: UiStatus.failure, errorMessage: err, smsSent: false));
        _effects.add(AcceptShowError(err));
        return;
      }

      emit(state.copyWith(status: UiStatus.success, smsSent: true, amount: amount));
      _effects.add(AcceptOpenSmsDialog(orderId: orderId, amount: amount));
    } catch (e) {
      emit(state.copyWith(status: UiStatus.failure, errorMessage: e.toString(), smsSent: false));
      _effects.add(AcceptShowError(e.toString()));
    }
  }

  /// 2) проверить SMS код и подтвердить
  Future<void> confirmSms({
    required int code,
    required int orderId,
    int serviceInsurance = 0,
    int creditDoctor = 0,
    int acceptRecurrent = 1,
    int acceptContract = 1,
    int isStarOracle = 0,
  }) async {
    emit(state.copyWith(status: UiStatus.loading, errorMessage: null));

    try {
      final err = await _repo.checkSms(
        code: code,
        orderId: orderId,
        serviceInsurance: serviceInsurance,
        creditDoctor: creditDoctor,
        acceptRecurrent: acceptRecurrent,
        acceptContract: acceptContract,
        isStarOracle: isStarOracle,
      );

      if (err.isNotEmpty) {
        emit(state.copyWith(status: UiStatus.failure, errorMessage: err));
        _effects.add(AcceptShowError(err));
        return;
      }

      final updated = await _repo.update1s();
      if (!updated) {
        emit(state.copyWith(status: UiStatus.failure, errorMessage: 'Не удалось обновить данные'));
        _effects.add(const AcceptShowError('Не удалось обновить данные'));
        return;
      }

      emit(state.copyWith(status: UiStatus.success, success: true));
      _effects.add(const AcceptCloseDialog());

      _startCheckLoanTimer(orderId: orderId);
    } catch (e) {
      emit(state.copyWith(status: UiStatus.failure, errorMessage: e.toString()));
      _effects.add(AcceptShowError(e.toString()));
    }
  }

  void _startCheckLoanTimer({required int orderId}) {
    _checkLoanTimer?.cancel();
    _checkLoanTimer = Timer.periodic(const Duration(minutes: 3), (_) async {
      try {
        final ok = await _repo.update1s();
        if (!ok) return;

        // дальше ты просто обновляешь заказы через OrdersCubit в UI
        // тут кубит репозиторием заказы не тянет, чтобы не дублировать логику
      } catch (_) {}
    });
  }
}
