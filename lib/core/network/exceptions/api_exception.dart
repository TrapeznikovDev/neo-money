enum ApiErrorType {
  network,
  timeout,
  server,
  unauthorized,
  forbidden,
  notFound,
  validation,
  unknown,
}

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final Object? raw;

  const ApiException(this.message, {this.statusCode, this.raw});

  @override
  String toString() => 'ApiException($statusCode): $message';
}

class UnauthorizedException extends ApiException {
  const UnauthorizedException(String message, {int? statusCode, Object? raw})
      : super(message, statusCode: statusCode, raw: raw);
}