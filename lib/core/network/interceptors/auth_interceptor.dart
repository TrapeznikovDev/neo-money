import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:neomoney/core/auth/token_storage.dart';

class AuthInterceptor extends Interceptor {
  final TokenStorage tokenStorage;

  AuthInterceptor(this.tokenStorage);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    if (options.headers.containsKey('Authorization')) {
      return handler.next(options);
    }

    final token = await tokenStorage.readAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    debugPrint('➡️ ${options.method} ${options.uri}');
    debugPrint('Headers: ${options.headers}');

    handler.next(options);
  }
}