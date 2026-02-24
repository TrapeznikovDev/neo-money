import 'package:dio/dio.dart';
import 'package:neomoney/core/network/headers/hash_headers.dart';

class HashHeadersInterceptor extends Interceptor {
  final HashHeaders hashHeaders;

  HashHeadersInterceptor(this.hashHeaders);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers.addAll(hashHeaders.build(DateTime.now()));
    handler.next(options);
  }
}