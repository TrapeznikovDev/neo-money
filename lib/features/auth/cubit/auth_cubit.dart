import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:neomoney/core/presentation/state/ui_state.dart';
import 'package:neomoney/features/auth/data/domain/auth_repository.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _repo;

  AuthCubit(this._repo) : super(const AuthState());

  void phoneChanged(String value) {
    final digits = value.replaceAll(RegExp(r'\D'), '');
    var normalized = digits;
    if (digits.length == 10) normalized = '7$digits';

    emit(state.copyWith(
      phone: normalized,
      status: state.status == UiStatus.failure ? UiStatus.initial : state.status,
      errorMessage: null,
      nextRoute: AuthNextRoute.none,
    ));
  }

  void smsCodeChanged(String code) {
    emit(state.copyWith(
      smsCode: code,
      status: state.status == UiStatus.failure ? UiStatus.initial : state.status,
      errorMessage: null,
      nextRoute: AuthNextRoute.none,
    ));
  }

  Future<void> requestSmsCode() async {
    if (state.phone.length < 11) {
      emit(state.copyWith(status: UiStatus.failure, errorMessage: 'Введите корректный номер телефона'));
      return;
    }

    emit(state.copyWith(status: UiStatus.loading, errorMessage: null, nextRoute: AuthNextRoute.none));

    try {
      await _repo.requestSms(phone: state.phone);

      // ✅ НЕ success — просто показываем поле кода
      emit(state.copyWith(
        status: UiStatus.initial,
        isCodeRequested: true,
      ));
    } catch (e) {
      emit(state.copyWith(status: UiStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> confirmSmsCode() async {
    if (state.smsCode.trim().length < 4) {
      emit(state.copyWith(status: UiStatus.failure, errorMessage: 'Введите код из СМС'));
      return;
    }

    emit(state.copyWith(status: UiStatus.loading, errorMessage: null, nextRoute: AuthNextRoute.none));

    try {
      final res = await _repo.confirmSms(phone: state.phone, code: state.smsCode.trim());

      // ✅ “как в boostra”: токен уже сохранён в репозитории
      // ✅ дальше — развилка по isRegistered
      emit(state.copyWith(
        status: UiStatus.success,
        nextRoute: res.isRegistered ? AuthNextRoute.home : AuthNextRoute.registration,
      ));
    } catch (e) {
      emit(state.copyWith(status: UiStatus.failure, errorMessage: e.toString()));
    }
  }

  /// ✅ чтобы BaseBlocPage listener не навигировал повторно
  void consumeNextRoute() {
    if (state.nextRoute == AuthNextRoute.none) return;
    emit(state.copyWith(nextRoute: AuthNextRoute.none, status: UiStatus.initial));
  }
}