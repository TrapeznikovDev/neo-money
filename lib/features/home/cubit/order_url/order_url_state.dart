// features/orders/bloc/order_url/order_url_state.dart
import 'package:equatable/equatable.dart';
import 'package:neomoney/core/presentation/state/ui_state.dart';

class OrderUrlState extends Equatable {
  final UiStatus status;
  final String? errorMessage;

  final String? url;

  /// флажок для кейса "ждём pop с webview"
  final bool waitingForPop;

  const OrderUrlState({
    this.status = UiStatus.initial,
    this.errorMessage,
    this.url,
    this.waitingForPop = false,
  });

  OrderUrlState copyWith({
    UiStatus? status,
    String? errorMessage,
    String? url,
    bool? waitingForPop,
  }) {
    return OrderUrlState(
      status: status ?? this.status,
      errorMessage: errorMessage,
      url: url ?? this.url,
      waitingForPop: waitingForPop ?? this.waitingForPop,
    );
  }

  @override
  List<Object?> get props => [status, errorMessage, url, waitingForPop];
}