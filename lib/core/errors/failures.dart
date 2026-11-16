import 'package:equatable/equatable.dart';

/// Base failure class for the application.
///
/// All domain-layer failures should extend this class.
/// Used with `Either<Failure, T>` from fpdart.
abstract class Failure extends Equatable {
  const Failure({required this.message, this.statusCode});

  /// Human-readable error message.
  final String message;

  /// Optional HTTP status code associated with the failure.
  final int? statusCode;

  @override
  List<Object?> get props => [message, statusCode];
}

/// Failure originating from a remote server/API call.
class ServerFailure extends Failure {
  const ServerFailure({
    required super.message,
    super.statusCode,
    this.code,
    this.field,
  });

  final String? code;
  final String? field;

  @override
  List<Object?> get props => [
        message,
        statusCode,
        if (code != null) code,
        if (field != null) field,
      ];
}

/// Validation failure on an input field.
class ValidationFailure extends ServerFailure {
  const ValidationFailure({
    required super.message,
    super.field,
    super.statusCode = 422,
    super.code = 'VALIDATION_ERROR',
  });
}

/// Unauthorized failure (session expired or invalid credentials).
class UnauthorizedFailure extends ServerFailure {
  const UnauthorizedFailure({
    super.message = 'Unauthorized. Please sign in again.',
    super.statusCode = 401,
    super.code = 'UNAUTHORIZED',
  });
}

/// Resource not found.
class NotFoundFailure extends ServerFailure {
  const NotFoundFailure({
    required super.message,
    super.statusCode = 404,
    super.code = 'NOT_FOUND',
  });
}

/// State conflict error.
class ConflictFailure extends ServerFailure {
  const ConflictFailure({
    required super.message,
    super.statusCode = 409,
    super.code = 'CONFLICT',
  });
}

/// Rate limit reached.
class RateLimitFailure extends ServerFailure {
  const RateLimitFailure({
    super.message = 'Too many requests. Please wait a moment and try again.',
    this.retryAfterSeconds,
    super.statusCode = 429,
    super.code = 'RATE_LIMITED',
  });

  final int? retryAfterSeconds;

  @override
  List<Object?> get props => [message, statusCode, code, retryAfterSeconds];
}

/// Failure originating from local cache/storage operations.
class CacheFailure extends Failure {
  const CacheFailure({required super.message});
}

/// Failure due to no network connectivity.
class NetworkFailure extends Failure {
  const NetworkFailure({
    super.message = 'No internet connection. Please check your network.',
  });
}

/// Failure for unexpected/unknown errors.
class UnexpectedFailure extends Failure {
  const UnexpectedFailure({
    super.message = 'An unexpected error occurred. Please try again.',
  });
}
