import 'package:equatable/equatable.dart';
import 'package:neomoney/core/presentation/state/ui_state.dart';

class AcceptOrderState extends Equatable {
  final UiStatus status;
  final String? errorMessage;

  final bool smsSent;
  final bool success;
  final double? amount;

  const AcceptOrderState({
    this.status = UiStatus.initial,
    this.errorMessage,
    this.smsSent = false,
    this.success = false,
    this.amount,
  });

  AcceptOrderState copyWith({
    UiStatus? status,
    String? errorMessage,
    bool? smsSent,
    bool? success,
    double? amount,
  }) {
    return AcceptOrderState(
      status: status ?? this.status,
      errorMessage: errorMessage,
      smsSent: smsSent ?? this.smsSent,
      success: success ?? this.success,
      amount: amount ?? this.amount,
    );
  }

  @override
  List<Object?> get props => [status, errorMessage, smsSent, success, amount];
}