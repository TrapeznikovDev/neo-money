import 'package:neomoney/core/presentation/state/ui_state.dart';
import 'package:neomoney/features/cards/data/models/card_model.dart';
import 'package:neomoney/features/home/screens/main/data/models/order_model.dart';
import 'package:neomoney/features/home/screens/main/data/models/payment_item_model.dart';
import 'package:neomoney/features/home/screens/main/data/models/user_model.dart';

class OrdersState implements UiState {
  @override
  final UiStatus status;

  @override
  final String? errorMessage;

  final List<OrderModel> orders;
  final List<CardModel> cards;
  final UserModel? user;

  final bool buttonLoading;
  final bool showBanner;
  final String? bannerLink;

  final List<PaymentItemModel> payments;
  final UiStatus paymentsStatus;
  final String? paymentsErrorMessage;

  const OrdersState({
    required this.status,
    required this.errorMessage,
    required this.orders,
    required this.cards,
    required this.user,
    required this.buttonLoading,
    required this.showBanner,
    required this.bannerLink,
    required this.payments,
    required this.paymentsStatus,
    required this.paymentsErrorMessage,
  });

  const OrdersState.initial()
    : status = UiStatus.initial,
      errorMessage = null,
      orders = const [],
      cards = const [],
      user = null,
      buttonLoading = false,
      showBanner = false,
      bannerLink = null,
      payments = const [],
      paymentsStatus = UiStatus.initial,
      paymentsErrorMessage = null;

  OrdersState copyWith({
    UiStatus? status,
    String? errorMessage,
    List<OrderModel>? orders,
    List<CardModel>? cards,
    UserModel? user,
    bool? buttonLoading,
    bool? showBanner,
    String? bannerLink,
    List<PaymentItemModel>? payments,
    UiStatus? paymentsStatus,
    String? paymentsErrorMessage,
  }) {
    return OrdersState(
      status: status ?? this.status,
      errorMessage: errorMessage,
      orders: orders ?? this.orders,
      cards: cards ?? this.cards,
      user: user ?? this.user,
      buttonLoading: buttonLoading ?? this.buttonLoading,
      showBanner: showBanner ?? this.showBanner,
      bannerLink: bannerLink ?? this.bannerLink,
      payments: payments ?? this.payments,
      paymentsStatus: paymentsStatus ?? this.paymentsStatus,
      paymentsErrorMessage: paymentsErrorMessage ?? this.paymentsErrorMessage,
    );
  }
}
