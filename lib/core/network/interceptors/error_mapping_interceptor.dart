import 'package:dio/dio.dart';
import 'package:neomoney/core/ui/notifications/app_toast.dart';

class ErrorMappingInterceptor extends Interceptor {
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final code = response.statusCode ?? 0;

    if (code >= 400) {
      AppToast.showError('Ошибка: $code');
    }

    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final code = err.response?.statusCode;
    if (code != 401) {
      final msg = _extractMessage(err) ?? 'Ошибка сети. Попробуйте позже.';
      AppToast.showError(msg);
    }
    super.onError(err, handler);
  }

  String? _extractMessage(DioException err) {
    final data = err.response?.data;
    if (data is Map<String, dynamic>) {
      return (data['message'] ?? data['error'])?.toString();
    }
    return null;
  }
}