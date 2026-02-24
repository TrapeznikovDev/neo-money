// payment_fixation_state.dart
import 'package:neomoney/core/presentation/state/ui_state.dart';
import 'package:neomoney/features/home/screens/main/data/models/order_model.dart';
import 'dart:io';

class PaymentFixationState implements UiState {
  @override
  final UiStatus status;
  @override
  final String? errorMessage;

  final OrderModel? order;
  final File? file;

  // Optionally include other flags like isLoading if needed
  const PaymentFixationState({
    required this.status,
    this.errorMessage,
    this.order,
    this.file,
  });

  // initial factory
  factory PaymentFixationState.initial() =>
      const PaymentFixationState(status: UiStatus.initial);

  PaymentFixationState copyWith({
    UiStatus? status,
    String? errorMessage,
    OrderModel? order,
    File? file,
  }) {
    return PaymentFixationState(
      status: status ?? this.status,
      errorMessage: errorMessage,
      order: order ?? this.order,
      file: file ?? this.file,
    );
  }
}