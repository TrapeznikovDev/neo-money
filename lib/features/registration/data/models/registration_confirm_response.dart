class RegistrationConfirmResponse {
  final String token;
  final bool isRegistered;
  final int userId;

  RegistrationConfirmResponse({
    required this.token,
    required this.isRegistered,
    required this.userId,
  });

  factory RegistrationConfirmResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    return RegistrationConfirmResponse(
      token: data['token'] as String,
      isRegistered: data['is_registered'] as bool,
      userId: data['user_id'] as int,
    );
  }
}