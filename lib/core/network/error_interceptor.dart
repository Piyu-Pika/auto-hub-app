import 'package:auto_hub_app/core/errors/exceptions.dart';
import 'package:dio/dio.dart';

/// Interceptor that normalizes HTTP errors into domain-specific [ServerException] types.
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final response = err.response;

    if (response != null && response.data is Map<String, dynamic>) {
      final data = response.data as Map<String, dynamic>;
      final errorMap = data['error'] as Map<String, dynamic>?;

      if (errorMap != null) {
        final code = errorMap['code'] as String?;
        final message = errorMap['message'] as String? ?? 'An error occurred.';
        final details = errorMap['details'] as Map<String, dynamic>?;
        final field = details?['field'] as String?;
        final statusCode = response.statusCode;

        ServerException exception;

        switch (statusCode) {
          case 422:
            exception = ValidationException(
              message: message,
              field: field,
            );
          case 401:
            exception = UnauthorizedException(
              message: message,
              code: code,
            );
          case 404:
            exception = NotFoundException(
              message: message,
            );
          case 409:
            exception = ConflictException(
              message: message,
              details: details,
            );
          case 429:
            final retryAfterHeader = response.headers.value('retry-after');
            final retrySeconds = retryAfterHeader != null
                ? int.tryParse(retryAfterHeader)
                : null;
            exception = RateLimitException(
              message: message,
              retryAfterSeconds: retrySeconds,
            );
          default:
            exception = ServerException(
              message: message,
              statusCode: statusCode,
              code: code,
              field: field,
              details: details,
            );
        }

        return handler.reject(
          DioException(
            requestOptions: err.requestOptions,
            response: err.response,
            type: err.type,
            error: exception,
            message: message,
          ),
        );
      }
    }

    // Connectivity or timeout error
    if (err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.connectionError) {
      return handler.reject(
        DioException(
          requestOptions: err.requestOptions,
          error: const NetworkException(
            message: 'Network connection error. Please check your internet.',
          ),
          message: 'Network connection error. Please check your internet.',
        ),
      );
    }

    handler.next(err);
  }
}
