import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TimerAuthCubit extends Cubit<TimerAuthState> {
  Timer? _timer;

  TimerAuthCubit() : super(const TimerAuthState());

  void start({int seconds = 30}) {
    _timer?.cancel();
    emit(TimerAuthState(startedOnce: true, secondsLeft: seconds));

    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      final next = state.secondsLeft - 1;
      if (next <= 0) {
        t.cancel();
        emit(state.copyWith(secondsLeft: 0));
      } else {
        emit(state.copyWith(secondsLeft: next));
      }
    });
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}

class TimerAuthState extends Equatable {
  final bool startedOnce;
  final int secondsLeft;

  const TimerAuthState({this.startedOnce = false, this.secondsLeft = 0});

  TimerAuthState copyWith({bool? startedOnce, int? secondsLeft}) {
    return TimerAuthState(
      startedOnce: startedOnce ?? this.startedOnce,
      secondsLeft: secondsLeft ?? this.secondsLeft,
    );
  }

  @override
  List<Object?> get props => [startedOnce, secondsLeft];
}