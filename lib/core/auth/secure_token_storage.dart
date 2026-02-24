import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'token_storage.dart';

class SecureTokenStorage implements TokenStorage {
  static const _kAccessTokenKey = 'access_token';

  final FlutterSecureStorage _storage;

  SecureTokenStorage({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  @override
  Future<void> clear() => _storage.delete(key: _kAccessTokenKey);

  @override
  Future<String?> readAccessToken() => _storage.read(key: _kAccessTokenKey);

  @override
  Future<void> writeAccessToken(String token) => _storage.write(
    key: _kAccessTokenKey,
    value: token,
  );
}