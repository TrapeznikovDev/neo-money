import 'package:dio/dio.dart';
import 'package:neomoney/core/network/singning/request_signer.dart';

class SignatureHeadersInterceptor extends Interceptor {
  final RequestSigner signer;
  final String Function() versionProvider;

  SignatureHeadersInterceptor({
    required this.signer,
    required this.versionProvider,
  });

  static const _signatureKeys = <String>{
    'req-time',
    'timestamp',
    'version',
    'auth-hash',
    'site-id',
  };

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final now = DateTime.now();

    final signature = signer.buildSignatureHeaders(
      now: now,
      version: versionProvider(),
    );

    final extra = options.extra;

    final bool skipSiteId = extra['skip_site_id'] == true;
    final bool skipSignature = extra['skip_signature_headers'] == true;

    if (skipSignature) {
      handler.next(options);
      return;
    }

    for (final key in _signatureKeys) {
      if (skipSiteId && key == 'site-id') continue;

      final v = signature[key];
      if (v == null) continue;

      options.headers.putIfAbsent(key, () => v);
    }

    handler.next(options);
  }
}