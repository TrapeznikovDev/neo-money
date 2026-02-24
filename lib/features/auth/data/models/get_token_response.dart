class GetTokenResponse {
  final String token;
  final bool isRegistered;
  final int userId;

  const GetTokenResponse({
    required this.token,
    required this.isRegistered,
    required this.userId,
  });

  factory GetTokenResponse.fromJson(Map<String, dynamic> json) {
    final data = (json['data'] as Map).cast<String, dynamic>();

    return GetTokenResponse(
      token: (data['token'] ?? '').toString(),
      isRegistered: data['is_registered'] == true,
      userId: (data['user_id'] as num).toInt(),
    );
  }
}