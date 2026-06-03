/// A simple Result wrapper for clean error handling across the app.
/// Replaces raw Map<String, dynamic> returns with type-safe results.
///
/// Usage:
///   final result = await loginUseCase.execute(email, password);
///   if (result.isSuccess) {
///     // use result.data
///   } else {
///     // show result.message
///   }
class ApiResult<T> {
  final bool isSuccess;
  final T? data;
  final String? message;

  const ApiResult._({
    required this.isSuccess,
    this.data,
    this.message,
  });

  factory ApiResult.success({T? data, String? message}) {
    return ApiResult._(isSuccess: true, data: data, message: message);
  }

  factory ApiResult.failure(String message) {
    return ApiResult._(isSuccess: false, message: message);
  }

  bool get isFailure => !isSuccess;
}
