import 'package:neomoney/core/network/api_client.dart';
import 'package:neomoney/features/auth/data/models/get_token_response.dart';
import 'auth_api.dart';

class AuthApiImpl implements AuthApi {
  final ApiClient _client;

  AuthApiImpl(this._client);

  @override
  Future<void> requestSms({required String phone}) async {
    await _client.post<Map<String, dynamic>>('v3/auth_sms', data: {'phone': phone,
      'backdoor': true
    });
  }

  @override
  Future<GetTokenResponse> getToken({required String phone, required String code}) async {
    final resp = await _client.post<Map<String, dynamic>>('get_token', data: {'phone': phone, 'code': code, 'utm_term': 'app_ios'});

    final body = resp.data;
    if (body == null || body is! Map<String, dynamic>) {
      throw Exception('Некорректный ответ сервера');
    }
    return GetTokenResponse.fromJson(body);
  }
}
