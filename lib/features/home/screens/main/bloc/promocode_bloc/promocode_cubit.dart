import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:neomoney/core/presentation/state/ui_state.dart';
import 'package:neomoney/features/home/screens/main/data/repository/promocode_repository.dart';

class PromoCodeCubit extends Cubit<PromoCodeState> {
  final PromoCodeRepository _repo;

  PromoCodeCubit(this._repo) : super(PromoCodeState.initial());

  Future<void> apply({required int orderId, VoidCallback? onApplied}) async {
    final code = state.controller.text.trim();
    if (orderId == 0 || code.isEmpty) {
      emit(state.copyWith(errorMessage: 'Введите промокод', success: false));
      return;
    }

    emit(state.copyWith(status: UiStatus.loading, errorMessage: null, success: false));

    try {
      await _repo.applyPromoCode(orderId: orderId, promocode: code);
      emit(state.copyWith(status: UiStatus.success, success: true));
      onApplied?.call();
    } catch (e) {
      emit(state.copyWith(status: UiStatus.failure, errorMessage: e.toString(), success: false));
    }
  }

  @override
  Future<void> close() {
    state.controller.dispose();
    return super.close();
  }
}

class PromoCodeState extends Equatable {
  final UiStatus status;
  final bool success;
  final String? errorMessage;
  final TextEditingController controller;

  const PromoCodeState({
    required this.status,
    required this.success,
    required this.errorMessage,
    required this.controller,
  });

  factory PromoCodeState.initial() => PromoCodeState(
    status: UiStatus.initial,
    success: false,
    errorMessage: null,
    controller: TextEditingController(),
  );

  PromoCodeState copyWith({
    UiStatus? status,
    bool? success,
    String? errorMessage,
  }) {
    return PromoCodeState(
      status: status ?? this.status,
      success: success ?? this.success,
      errorMessage: errorMessage,
      controller: controller,
    );
  }

  @override
  List<Object?> get props => [status, success, errorMessage];
}