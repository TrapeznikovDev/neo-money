import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:neomoney/features/home/screens/main/data/repository/orders_repository.dart';

part 'order_cooling_down_state.dart';

class OrderCoolingDownCubit extends Cubit<OrderCoolingDownState> {
  final OrderRepository _repo;

  Timer? _timer;

  static const String _zero = '00:00:00';
  static const Duration _coolDown = Duration(hours: 4);

  OrderCoolingDownCubit(this._repo) : super(const OrderCoolingDownState());

  Future<void> refuseCoolingOrder(int orderId) async {
    emit(state.copyWith(loading: true, error: '', success: false));

    try {
      final error = await _repo.refuseCoolingOrder(orderId);

      emit(
        state.copyWith(
          loading: false,
          error: error,
          success: error.isEmpty,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          loading: false,
          error: e.toString(),
          success: false,
        ),
      );
    }
  }

  void startTimer(String confirmDate) {
    _timer?.cancel();

    final confirmDateTime = _parseConfirmDate(confirmDate);
    if (confirmDateTime == null) {
      emit(state.copyWith(timeLeft: _zero));
      return;
    }

    void tick() {
      final now = DateTime.now();

      // если подтверждение ещё в будущем — показываем 00:00:00
      if (now.isBefore(confirmDateTime)) {
        emit(state.copyWith(timeLeft: _zero));
        return;
      }

      final endTime = confirmDateTime.add(_coolDown);
      final remaining = endTime.difference(now);

      if (remaining.isNegative || remaining == Duration.zero) {
        emit(state.copyWith(timeLeft: _zero));
        _timer?.cancel();
        return;
      }

      emit(state.copyWith(timeLeft: _formatDuration(remaining)));
    }

    tick();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => tick());
  }

  DateTime? _parseConfirmDate(String raw) {
    // "2026-02-04 12:34:56" -> ISO "2026-02-04T12:34:56"
    final normalized = raw.trim().replaceFirst(' ', 'T');
    return DateTime.tryParse(normalized);
  }

  String _formatDuration(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    final h = two(d.inHours);
    final m = two(d.inMinutes.remainder(60));
    final s = two(d.inSeconds.remainder(60));
    return '$h:$m:$s';
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}