class TokenResponse {
  final String accessToken;

  TokenResponse({required this.accessToken});

  factory TokenResponse.fromJson(dynamic json) {
    if (json is Map<String, dynamic>) {
      final data = json['data'];
      final token1 = data is Map<String, dynamic> ? (data['token'] ?? data['access_token']) : null;
      final token2 = json['token'] ?? json['access_token'];

      final token = (token1 ?? token2)?.toString();
      if (token == null || token.isEmpty) {
        throw const FormatException('Token not found in response');
      }
      return TokenResponse(accessToken: token);
    }

    throw const FormatException('Invalid token response');
  }
}