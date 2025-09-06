// Flutter imports:

class HttpResponse {
  const HttpResponse._({
    required this.data,
    required this.statusCode,
    required this.message,
  });

  final Object data;
  final int statusCode;
  final String message;

  factory HttpResponse.success({
    required Object data,
    required int statusCode,
  }) {
    return SuccessHttpResponse(data: data, statusCode: statusCode);
  }

  factory HttpResponse.failure({
    required Object data,
    required int statusCode,
  }) {
    return FailureHttpResponse(data: data, statusCode: statusCode);
  }

  factory HttpResponse.exception({
    required String message,
    required int code,
    required StackTrace stackTrace,
    required Object detail,
  }) {
    return ExceptionHttpResponse(
      message: message,
      code: code,
      stackTrace: stackTrace,
      detail: detail,
    );
  }
}

class SuccessHttpResponse extends HttpResponse {
  @override
  final Object data;
  @override
  final int statusCode;

  const SuccessHttpResponse({required this.data, required this.statusCode})
    : super._(data: data, statusCode: statusCode, message: 'Success');

  @override
  String toString() {
    return 'SuccessHttpResponse{data: $data, statusCode: $statusCode}';
  }
}

class FailureHttpResponse extends HttpResponse {
  @override
  final Object data;
  @override
  final int statusCode;

  const FailureHttpResponse({required this.data, required this.statusCode})
    : super._(data: data, statusCode: statusCode, message: 'Failure');

  @override
  String toString() {
    return 'FailureHttpResponse{data: $data, statusCode: $statusCode}';
  }
}

class ExceptionHttpResponse extends HttpResponse {
  @override
  final String message;
  final int code;
  final StackTrace stackTrace;
  final Object detail;

  const ExceptionHttpResponse({
    required this.message,
    required this.code,
    required this.stackTrace,
    required this.detail,
  }) : super._(data: detail, message: message, statusCode: code);

  @override
  String toString() {
    return 'ExceptionHttpResponse{message: $message, code: $code, stackTrace: $stackTrace, detail: $detail}';
  }
}
