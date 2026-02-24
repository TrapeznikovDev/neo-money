import 'package:dio/dio.dart';
import 'package:neomoney/core/network/exceptions/api_exception.dart';

class ApiClient {
  final Dio _dio;

  ApiClient(this._dio);

  Future<Response<T>> request<T>(
      String path, {
        required String method,
        Object? data,
        Map<String, dynamic>? queryParameters,
        Options? options,
      }) async {
    try {
      return await _dio.request<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: (options ?? Options()).copyWith(method: method),
      );
    } on DioException catch (e) {
      throw _mapDio(e);
    }
  }

  Future<Response<T>> get<T>(
      String path, {
        Map<String, dynamic>? queryParameters,
        Options? options,
      }) =>
      request<T>(path, method: 'GET', queryParameters: queryParameters, options: options);

  Future<Response<T>> post<T>(
      String path, {
        Object? data,
        Map<String, dynamic>? queryParameters,
        Options? options,
      }) =>
      request<T>(path, method: 'POST', data: data, queryParameters: queryParameters, options: options);

  Future<Response<T>> put<T>(
      String path, {
        Object? data,
        Map<String, dynamic>? queryParameters,
        Options? options,
      }) =>
      request<T>(path, method: 'PUT', data: data, queryParameters: queryParameters, options: options);

  Future<Response<T>> delete<T>(
      String path, {
        Object? data,
        Map<String, dynamic>? queryParameters,
        Options? options,
      }) =>
      request<T>(path, method: 'DELETE', data: data, queryParameters: queryParameters, options: options);

  ApiException _mapDio(DioException e) {
    final status = e.response?.statusCode;

    // Отмена запроса — не “ошибка бэка”
    if (e.type == DioExceptionType.cancel) {
      return ApiException('Запрос отменён', statusCode: status, raw: e);
    }

    final msg = _extractMessage(e) ?? _fallbackMessage(e);

    if (status == 401) {
      return UnauthorizedException(msg, statusCode: status, raw: e);
    }

    return ApiException(msg, statusCode: status, raw: e);
  }

  String _fallbackMessage(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Превышено время ожидания';
      case DioExceptionType.connectionError:
        return 'Нет соединения с интернетом';
      default:
        return 'Ошибка сети';
    }
  }

  String? _extractMessage(DioException e) {
    final data = e.response?.data;

    if (data is Map) {
      final message = data['message'] ?? data['error'];
      if (message is String && message.isNotEmpty) return message;

      final errors = data['errors'];
      if (errors is Map) {
        // errors: {field: [msg1, msg2]}
        for (final entry in errors.entries) {
          final v = entry.value;
          if (v is List && v.isNotEmpty) return v.first.toString();
          if (v is String && v.isNotEmpty) return v;
        }
      }
    }

    if (data is String && data.trim().isNotEmpty) return data;

    return e.message;
  }
}