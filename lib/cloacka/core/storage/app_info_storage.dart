import 'package:shared_preferences/shared_preferences.dart';

class AppInfoStorage {
  static const _regPhone = 'reg_phone_number';
  static const _regCode = 'reg_sms_code';
  static const _authPhone = 'auth_phone_number';
  static const _authCode = 'auth_sms_code';
  static const _cloacaVersion = 'cloacka_ver_ios';
  static const _privacyPolicyUrl = 'privacy_policy_url';
  static const _registrationOrganizationInfo = 'registration_organization_info';

  final SharedPreferences _prefs;

  AppInfoStorage(this._prefs);

  Future<void> save({
    String? regPhone,
    String? regCode,
    String? authPhone,
    String? authCode,
    String? cloacaVersion,
    String? privacyPolicyUrl,
    String? registrationOrganizationInfo,
  }) async {
    if (regPhone != null) await _prefs.setString(_regPhone, regPhone);
    if (regCode != null) await _prefs.setString(_regCode, regCode);
    if (authPhone != null) await _prefs.setString(_authPhone, authPhone);
    if (authCode != null) await _prefs.setString(_authCode, authCode);
    if (cloacaVersion != null) await _prefs.setString(_cloacaVersion, cloacaVersion);
    if (privacyPolicyUrl != null) await _prefs.setString(_privacyPolicyUrl, privacyPolicyUrl);
    if (registrationOrganizationInfo != null) await _prefs.setString(_registrationOrganizationInfo, registrationOrganizationInfo);
  }

  String? get regPhone => _prefs.getString(_regPhone);
  String? get regCode => _prefs.getString(_regCode);
  String? get authPhone => _prefs.getString(_authPhone);
  String? get authCode => _prefs.getString(_authCode);
  String? get cloacaVersion => _prefs.getString(_cloacaVersion);
  String? get privacyPolicyUrl => _prefs.getString(_privacyPolicyUrl);
  String? get registrationOrganizationInfo => _prefs.getString(_registrationOrganizationInfo);
}