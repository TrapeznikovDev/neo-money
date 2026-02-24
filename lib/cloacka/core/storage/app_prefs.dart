import 'package:shared_preferences/shared_preferences.dart';

class AppPrefs {
  static const _kOnboardingDone = 'onboarding_done';
  static const _kIsAuthorized = 'is_authorized';
  static const _kCloacaEnabled = 'cloaca_enabled'; // ✅

  final SharedPreferences _sp;
  AppPrefs(this._sp);

  // onboarding
  bool get onboardingDone => _sp.getBool(_kOnboardingDone) ?? false;
  Future<void> setOnboardingDone() => _sp.setBool(_kOnboardingDone, true);

  // auth
  bool get isAuthorized => _sp.getBool(_kIsAuthorized) ?? false;
  Future<void> setAuthorized() => _sp.setBool(_kIsAuthorized, true);
  Future<void> logout() => _sp.remove(_kIsAuthorized);

  // ✅ cloaca enabled
  bool get cloacaEnabled => _sp.getBool(_kCloacaEnabled) ?? false;
  Future<void> setCloacaEnabled(bool v) => _sp.setBool(_kCloacaEnabled, v);
}