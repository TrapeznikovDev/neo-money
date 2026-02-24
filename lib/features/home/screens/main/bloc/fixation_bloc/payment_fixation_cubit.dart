// payment_fixation_cubit.dart
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:neomoney/core/presentation/state/ui_state.dart';
import 'package:neomoney/features/home/screens/main/data/models/order_model.dart';
import 'package:neomoney/features/home/screens/main/data/repository/orders_repository.dart';
import 'payment_fixation_state.dart';

class PaymentFixationCubit extends Cubit<PaymentFixationState> {
  final OrderRepository _orderRepository;

  PaymentFixationCubit(this._orderRepository)
      : super(PaymentFixationState.initial());

  void setOrder(OrderModel order) {
    emit(state.copyWith(order: order));
  }

  Future<void> pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      withData: false,
    );
    if (result != null) {
      final file = File(result.files.single.path!);
      final fileSize = await file.length();
      if (fileSize > 100 * 1024 * 1024) {
        emit(state.copyWith(errorMessage: 'Файл больше 100 МБ'));
        return;
      }
      emit(state.copyWith(file: file));
    }
  }

  void removeFile() {
    emit(state.copyWith(file: null));
  }

  Future<void> uploadReceipt() async {
    emit(state.copyWith(status: UiStatus.loading));
    try {
      final file = state.file;
      final order = state.order;
      if (file == null || order == null) {
        emit(state.copyWith(
            status: UiStatus.failure,
            errorMessage: 'Невозможно загрузить: отсутствуют файл или заказ'));
        return;
      }

      final success = await _orderRepository.uploadReceipt(file, order.orderId!);
      if(success){
        emit(state.copyWith(status: UiStatus.success));
      }else{
        emit(state.copyWith(status: UiStatus.failure, errorMessage: 'Не получилось загрузить'));
      }

    } catch (e) {
      emit(state.copyWith(
          status: UiStatus.failure, errorMessage: e.toString()));
    }
  }
}