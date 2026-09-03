abstract class ResponseModel<T> {}

class Success<T> extends ResponseModel<T> {
  final T data;
  Success(this.data);
}

class Failure<T> extends ResponseModel<T> {
  final String errorMessage;
  final int? statusCode;
  Failure({required this.errorMessage, this.statusCode});
}