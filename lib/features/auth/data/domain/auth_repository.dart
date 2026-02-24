import 'package:neomoney/features/auth/data/models/get_token_response.dart';

abstract class AuthRepository {
  Future<void> requestSms({required String phone});
  Future<GetTokenResponse> confirmSms({required String phone, required String code});
}