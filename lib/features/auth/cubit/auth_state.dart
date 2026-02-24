import 'package:neomoney/core/presentation/state/ui_state.dart';

enum AuthNextRoute { none, home, registration }

class AuthState implements UiState {
  @override
  final UiStatus status;
  @override
  final String? errorMessage;

  final String phone;
  final String smsCode;
  final bool isCodeRequested;

  final AuthNextRoute nextRoute;

  const AuthState({
    this.status = UiStatus.initial,
    this.errorMessage,
    this.phone = '',
    this.smsCode = '',
    this.isCodeRequested = false,
    this.nextRoute = AuthNextRoute.none,
  });

  AuthState copyWith({
    UiStatus? status,
    String? errorMessage,
    String? phone,
    String? smsCode,
    bool? isCodeRequested,
    AuthNextRoute? nextRoute,
  }) {
    return AuthState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      phone: phone ?? this.phone,
      smsCode: smsCode ?? this.smsCode,
      isCodeRequested: isCodeRequested ?? this.isCodeRequested,
      nextRoute: nextRoute ?? this.nextRoute,
    );
  }

  static AuthState initial() => const AuthState();
}