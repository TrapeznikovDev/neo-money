import 'package:neomoney/core/auth/token_storage.dart';
import 'package:neomoney/features/auth/data/domain/auth_repository.dart';
import 'package:neomoney/features/auth/data/models/get_token_response.dart';
import 'package:neomoney/features/auth/data/remote/auth_api.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthApi _api;
  final TokenStorage _tokenStorage;

  AuthRepositoryImpl(this._api, this._tokenStorage);

  @override
  Future<void> requestSms({required String phone}) {
    return _api.requestSms(phone: phone);
  }

  @override
  Future<GetTokenResponse> confirmSms({required String phone, required String code}) async {
    final result = await _api.getToken(phone: phone, code: code);
    await _tokenStorage.writeAccessToken(result.token);

    return result;
  }
}