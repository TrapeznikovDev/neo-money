class AppInfoDto {
  final String? regPhoneNumber;
  final String? regSmsCode;
  final String? authPhoneNumber;
  final String? authSmsCode;
  final String? cloacaVersion;
  final String? cloacaBuildVersion;
  final String? privacyPolicyUrl;
  final String? registrationOrganizationInfo;

  const AppInfoDto({
    this.regPhoneNumber,
    this.regSmsCode,
    this.authPhoneNumber,
    this.authSmsCode,
    this.cloacaVersion,
    this.cloacaBuildVersion,
    this.privacyPolicyUrl,
    this.registrationOrganizationInfo,
  });

  factory AppInfoDto.fromJson(Map<String, dynamic> json) {
    String? _s(dynamic v) => v == null ? null : v.toString();

    return AppInfoDto(
      regPhoneNumber: _s(json['reg_phone_number']),
      regSmsCode: _s(json['reg_sms_code']),
      authPhoneNumber: _s(json['auth_phone_number']),
      authSmsCode: _s(json['auth_sms_code']),
      cloacaVersion: _s(json['cloaca_ver_ios']),
      cloacaBuildVersion: _s(json['cloaca_build_ios']),
      privacyPolicyUrl: _s(json['privacy_policy_url']),
      registrationOrganizationInfo: _s(json['registration_organization_info']),
    );
  }
}