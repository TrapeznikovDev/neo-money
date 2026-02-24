part of 'order_cooling_down_cubit.dart';

class OrderCoolingDownState extends Equatable {
  final bool loading;
  final bool success;
  final String error;
  final String timeLeft;

  const OrderCoolingDownState({
    this.loading = false,
    this.success = false,
    this.error = '',
    this.timeLeft = '00:00:00',
  });

  OrderCoolingDownState copyWith({
    bool? loading,
    bool? success,
    String? error,
    String? timeLeft,
  }) {
    return OrderCoolingDownState(
      loading: loading ?? this.loading,
      success: success ?? this.success,
      error: error ?? this.error,
      timeLeft: timeLeft ?? this.timeLeft,
    );
  }

  @override
  List<Object?> get props => [loading, success, error, timeLeft];
}