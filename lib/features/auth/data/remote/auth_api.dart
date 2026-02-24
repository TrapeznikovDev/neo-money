import 'package:neomoney/features/auth/data/models/get_token_response.dart';

abstract class AuthApi {
  Future<void> requestSms({required String phone});
  Future<GetTokenResponse> getToken({required String phone, required String code});
}