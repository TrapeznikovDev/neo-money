// features/orders/bloc/order_url/order_url_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:neomoney/core/presentation/state/ui_state.dart';
import 'package:neomoney/features/home/screens/main/data/repository/orders_repository.dart';
import 'order_url_state.dart';

class OrderUrlCubit extends Cubit<OrderUrlState> {
  final OrderRepository _repo;

  OrderUrlCubit(this._repo) : super(const OrderUrlState());

  Future<void> loadUrl({
    required int? cardId,
    required double amount,
    required int? prolPeriod,
    required String prolongation,
    required String orderNumber,
    String? smsCode,
    bool? sendLoanAfterClosing,
    bool? multipolis,
    bool? tvMedical,
    required String type, // 'b2p' | 'sbp'
    String? action,
    int? chdp,
  }) async {
    emit(state.copyWith(status: UiStatus.loading, errorMessage: null, url: null));

    try {
      final url = await _repo.getPaymentUrl(
        cardId: cardId,
        amount: amount,
        prolPeriod: prolPeriod,
        orderNumber: orderNumber,
        smsCode: smsCode,
        prolongation: prolongation,
        sendLoanAfterClosing: sendLoanAfterClosing,
        multipolis: multipolis,
        tvMedical: tvMedical,
        type: type,
        action: action,
        chdp: chdp,
      );

      if (url.contains('Неверный код')) {
        throw Exception(url);
      }

      emit(state.copyWith(status: UiStatus.success, url: url));
    } catch (e) {
      emit(state.copyWith(
        status: UiStatus.failure,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      ));
    }
  }

  void setWaitingForPop(bool value) {
    emit(state.copyWith(waitingForPop: value));
  }

  void clear() {
    emit(const OrderUrlState());
  }
}