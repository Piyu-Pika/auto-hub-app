/// Custom exception classes for the application.
///
/// Exceptions are thrown in the data layer and caught by repositories,
/// which convert them into Failure types for the domain layer.
library;

/// Exception thrown when a server/API call fails.
class ServerException implements Exception {
  const ServerException({
    required this.message,
    this.statusCode,
    this.code,
    this.field,
    this.details,
  });

  final String message;
  final int? statusCode;
  final String? code;
  final String? field;
  final Map<String, dynamic>? details;

  @override
  String toString() {
    if (code == null && field == null) {
      return 'ServerException(message: $message, '
          'statusCode: $statusCode)';
    }
    return 'ServerException(message: $message, '
        'statusCode: $statusCode, code: $code, field: $field)';
  }
}

/// Exception thrown when server returns 422 validation error.
class ValidationException extends ServerException {
  const ValidationException({
    required super.message,
    super.field,
    super.statusCode = 422,
    super.code = 'VALIDATION_ERROR',
  });
}

/// Exception thrown on 401 unauthorized.
class UnauthorizedException extends ServerException {
  const UnauthorizedException({
    super.message = 'Session expired. Please sign in again.',
    super.statusCode = 401,
    super.code = 'UNAUTHORIZED',
  });
}

/// Exception thrown on 404 not found.
class NotFoundException extends ServerException {
  const NotFoundException({
    required super.message,
    super.statusCode = 404,
    super.code = 'NOT_FOUND',
  });
}

/// Exception thrown on 409 conflict.
class ConflictException extends ServerException {
  const ConflictException({
    required super.message,
    super.statusCode = 409,
    super.code = 'CONFLICT',
    super.details,
  });
}

/// Exception thrown on 429 rate limited.
class RateLimitException extends ServerException {
  const RateLimitException({
    super.message = 'Too many requests. Please try again shortly.',
    this.retryAfterSeconds,
    super.statusCode = 429,
    super.code = 'RATE_LIMITED',
  });

  final int? retryAfterSeconds;
}

/// Exception thrown when a local cache operation fails.
class CacheException implements Exception {
  const CacheException({required this.message});

  final String message;

  @override
  String toString() => 'CacheException(message: $message)';
}

/// Exception thrown when there is no network connectivity.
class NetworkException implements Exception {
  const NetworkException({
    this.message = 'No internet connection.',
  });

  final String message;

  @override
  String toString() => 'NetworkException(message: $message)';
}
