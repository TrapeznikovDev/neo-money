import 'package:dio/dio.dart';
import 'package:neomoney/core/network/api_client.dart';
import 'package:neomoney/core/auth/token_storage.dart';
import 'package:neomoney/core/network/interceptors/auth_interceptor.dart';
import 'package:neomoney/core/network/interceptors/logging_interceptor.dart';
import 'package:neomoney/core/network/interceptors/signature_headers_interceptor.dart';
import 'package:neomoney/core/network/interceptors/unauthorized_redirect_interceptor.dart';
import 'package:neomoney/core/network/singning/request_signer.dart';

class DioProvider {
  final String baseUrl;
  final TokenStorage tokenStorage;
  final RequestSigner signer;

  final String Function() versionProvider;

  final void Function() onUnauthorized;

  final bool enableLogs;

  final Set<String> authExcludedLastSegments;

  DioProvider({
    required this.baseUrl,
    required this.tokenStorage,
    required this.signer,
    required this.versionProvider,
    required this.onUnauthorized,
    this.enableLogs = false,
    Set<String>? authExcludedLastSegments,
  }) : authExcludedLastSegments = authExcludedLastSegments ??
      const {
        'by_phone',
        'by_phone_confirm',
        'auth_sms',
        'login',
        'get_token',
      };

  ApiClient createApiClient() {
    final dio = Dio(_buildOptions());

    dio.interceptors.addAll([
      SignatureHeadersInterceptor(
        signer: signer,
        versionProvider: versionProvider,
      ),

      AuthInterceptor(tokenStorage),

      LoggingInterceptor(enabled: enableLogs),

      UnauthorizedRedirectInterceptor(
        tokenStorage: tokenStorage,
        onUnauthorized: onUnauthorized,
        excludedLastSegments: authExcludedLastSegments,
      ),
    ]);

    return ApiClient(dio);
  }

  BaseOptions _buildOptions() {
    final normalized = _normalizeBaseUrl(baseUrl);

    return BaseOptions(
      baseUrl: normalized,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 25),
      sendTimeout: const Duration(seconds: 15),

      headers: const {
        'Accept': 'application/json',
      },

      validateStatus: (code) => code != null && code >= 200 && code < 300,
      responseType: ResponseType.json,
    );
  }

  String _normalizeBaseUrl(String url) {
    final trimmed = url.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError('baseUrl is empty');
    }
    return trimmed.endsWith('/') ? trimmed : '$trimmed/';
  }
}