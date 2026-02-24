import 'dart:async';

import 'package:dio/dio.dart';
import 'package:neomoney/core/auth/token_storage.dart';

class UnauthorizedRedirectInterceptor extends Interceptor {
  final TokenStorage tokenStorage;
  final void Function() onUnauthorized;
  final Set<String> excludedLastSegments;

  // Глобальная “одноразовая” обработка 401 (пока не завершится текущая)
  Completer<void>? _handlingCompleter;

  UnauthorizedRedirectInterceptor({
    required this.tokenStorage,
    required this.onUnauthorized,
    required this.excludedLastSegments,
  });

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final status = err.response?.statusCode;

    // Иногда удобнее отключать редирект точечно на конкретном запросе
    final skipRedirect = err.requestOptions.extra['skipAuthRedirect'] == true;
    if (skipRedirect) {
      return handler.next(err);
    }

    final last = _lastSegment(err.requestOptions);

    final shouldIgnore = excludedLastSegments.contains(last);

    if (status == 401 && !shouldIgnore) {
      // Если уже обрабатываем 401 — просто ждём и пропускаем ошибку дальше
      final ongoing = _handlingCompleter;
      if (ongoing != null) {
        await ongoing.future;
        return handler.next(err);
      }

      final completer = Completer<void>();
      _handlingCompleter = completer;

      try {
        await tokenStorage.clear();

        // Навигацию/редирект безопаснее дергать асинхронно,
        // чтобы не конфликтовать с текущим фреймом/контекстом.
        scheduleMicrotask(onUnauthorized);
      } finally {
        completer.complete();
        _handlingCompleter = null;
      }
    }

    handler.next(err);
  }

  String _lastSegment(RequestOptions o) {
    final segments = o.uri.pathSegments;
    return segments.isNotEmpty ? segments.last : '';
  }
}