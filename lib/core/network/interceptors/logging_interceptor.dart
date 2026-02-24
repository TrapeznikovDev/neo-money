import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class LoggingInterceptor extends Interceptor {
  final bool enabled;
  final int maxBodyChars;

  LoggingInterceptor({
    required this.enabled,
    this.maxBodyChars = 2000,
  });

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (!enabled) return handler.next(options);

    final id = options.extra['reqId'] ??= DateTime.now().microsecondsSinceEpoch.toString();

    debugPrint('[DIO][$id] --> ${options.method} ${options.uri}');
    debugPrint('[DIO][$id] headers: ${_safeHeaders(options.headers)}');

    if (options.queryParameters.isNotEmpty) {
      debugPrint('[DIO][$id] query: ${options.queryParameters}');
    }

    if (options.data != null) {
      debugPrint('[DIO][$id] body: ${_truncate(_stringify(options.data))}');
    }

    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (!enabled) return handler.next(response);

    final id = response.requestOptions.extra['reqId'] ?? '-';
    debugPrint('[DIO][$id] <-- ${response.statusCode} ${response.requestOptions.uri}');

    if (response.data != null) {
      debugPrint('[DIO][$id] data: ${_truncate(_stringify(response.data))}');
    }

    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (!enabled) return handler.next(err);

    final id = err.requestOptions.extra['reqId'] ?? '-';
    final status = err.response?.statusCode;

    debugPrint('[DIO][$id] xx ${err.type} status=$status ${err.requestOptions.uri}');
    debugPrint('[DIO][$id] message: ${err.message}');

    if (err.response?.data != null) {
      debugPrint('[DIO][$id] errorBody: ${_truncate(_stringify(err.response?.data))}');
    }

    handler.next(err);
  }

  Map<String, dynamic> _safeHeaders(Map<String, dynamic> headers) {
    final copy = Map<String, dynamic>.from(headers);
    for (final key in ['Authorization', 'authorization', 'cookie', 'Cookie']) {
      if (copy.containsKey(key)) copy[key] = '***';
    }
    return copy;
  }

  String _truncate(String s) {
    if (s.length <= maxBodyChars) return s;
    return '${s.substring(0, maxBodyChars)}... (${s.length} chars)';
  }

  String _stringify(Object? data) {
    if (data == null) return 'null';
    try {
      if (data is String) return data;
      return const JsonEncoder.withIndent('  ').convert(data);
    } catch (_) {
      return data.toString();
    }
  }
}