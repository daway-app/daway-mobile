import '../erroring/failure.dart';

sealed class ApiResult<T> {
  const ApiResult();
}

class Success<T> extends ApiResult<T> {
  final T data;
  const Success(this.data);
}

class ApiError<T> extends ApiResult<T> {
  final Failure failure;
  const ApiError(this.failure);
}
