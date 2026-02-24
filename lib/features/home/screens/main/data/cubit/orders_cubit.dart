import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:neomoney/core/auth/token_storage.dart';
import 'package:neomoney/core/presentation/state/ui_state.dart';
import 'package:neomoney/features/home/screens/main/data/cubit/orders_state.dart';
import 'package:neomoney/features/home/screens/main/data/repository/orders_repository.dart';

class OrdersCubit extends Cubit<OrdersState> {
  final OrderRepository _repo;
  final TokenStorage _tokenStorage;

  OrdersCubit(this._repo, this._tokenStorage) : super(const OrdersState.initial());

  Future<void> init() async {
    if (state.status == UiStatus.initial) {
      await load();
    }
  }

  Future<void> load() async {
    emit(state.copyWith(status: UiStatus.loading, errorMessage: null));
    try {
      final orders = await _repo.getOrders();
      final user = await _repo.getUser();
      final cards = await _repo.getCards();

      final showBanner = (user.showBanner ?? 0) == 1;
      final bannerLink = user.bannerLink;

      emit(state.copyWith(
        status: UiStatus.success,
        orders: orders,
        user: user,
        showBanner: showBanner,
        bannerLink: bannerLink,
        cards: cards
      ));
    } catch (e) {
      emit(state.copyWith(status: UiStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> refresh() => load();

  Future<void> logout() async {
    await _tokenStorage.clear();
  }

  void onBannerTap() {
    final link = state.bannerLink;
    if (link == null || link.isEmpty) return;
  }

  Future<void> fetchPaymentScheduleNf(int orderId) async {
    emit(state.copyWith(
      paymentsStatus: UiStatus.loading,
      paymentsErrorMessage: null,
    ));

    try {
      final payments = await _repo.fetchPaymentSchedule(orderId);
      emit(state.copyWith(
        paymentsStatus: UiStatus.success,
        payments: payments,
      ));
    } catch (e) {
      emit(state.copyWith(
        paymentsStatus: UiStatus.failure,
        paymentsErrorMessage: e.toString(),
        payments: const [],
      ));
    }
  }

  Future<void> sendLoan() async{
    //todo решить вопрос
    // try{
    //   await _repo.sendLoan(amount, term, cardId, cardType);
    //
    // }catch (e){
    //
    // }
  }
}