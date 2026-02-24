sealed class ApiResult<T> {
  const ApiResult();
}

class ApiSuccess<T> extends ApiResult<T> {
  final T data;
  const ApiSuccess(this.data);
}

class ApiFailure<T> extends ApiResult<T> {
  final Object error;
  final StackTrace? stackTrace;
  const ApiFailure(this.error, {this.stackTrace});
}