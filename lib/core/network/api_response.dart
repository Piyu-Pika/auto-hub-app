import 'package:auto_hub_app/core/errors/exceptions.dart';

/// Standard response envelope for AutoHub Express Customer API.
class ApiResponse<T> {
  const ApiResponse({
    required this.success,
    this.data,
    this.meta,
    this.error,
    this.requestId,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic json) fromJsonT,
  ) {
    final success = json['success'] as bool? ?? false;
    final requestId = json['requestId'] as String?;

    if (!success) {
      final errorMap = json['error'] as Map<String, dynamic>?;
      final apiError = errorMap != null ? ApiError.fromJson(errorMap) : null;
      return ApiResponse<T>(
        success: false,
        error: apiError,
        requestId: requestId,
      );
    }

    final dataJson = json['data'];
    final data = dataJson != null ? fromJsonT(dataJson) : null;

    final metaMap = json['meta'] as Map<String, dynamic>?;
    final meta = metaMap != null ? ApiMeta.fromJson(metaMap) : null;

    return ApiResponse<T>(
      success: true,
      data: data,
      meta: meta,
      requestId: requestId,
    );
  }

  final bool success;
  final T? data;
  final ApiMeta? meta;
  final ApiError? error;
  final String? requestId;

  /// Unwraps the data or throws a [ServerException].
  T get requireData {
    if (!success || data == null) {
      throw ServerException(
        message: error?.message ?? 'An unexpected error occurred.',
        statusCode: null,
      );
    }
    return data!;
  }
}

/// Metadata included in list endpoints.
class ApiMeta {
  const ApiMeta({
    this.page,
    this.limit,
    this.total,
    this.requestId,
    this.vehicle,
    this.hasMore,
    this.nextBefore,
  });

  factory ApiMeta.fromJson(Map<String, dynamic> json) {
    return ApiMeta(
      page: json['page'] as int?,
      limit: json['limit'] as int?,
      total: json['total'] as int?,
      requestId: json['requestId'] as String?,
      vehicle: json['vehicle'] as Map<String, dynamic>?,
      hasMore: json['hasMore'] as bool?,
      nextBefore: json['nextBefore'] as String?,
    );
  }

  final int? page;
  final int? limit;
  final int? total;
  final String? requestId;
  final Map<String, dynamic>? vehicle;
  final bool? hasMore;
  final String? nextBefore;
}

/// Error details returned in the response envelope.
class ApiError {
  const ApiError({
    required this.code,
    required this.message,
    this.details,
  });

  factory ApiError.fromJson(Map<String, dynamic> json) {
    return ApiError(
      code: json['code'] as String? ?? 'INTERNAL_ERROR',
      message: json['message'] as String? ?? 'An unexpected error occurred.',
      details: json['details'] as Map<String, dynamic>?,
    );
  }

  final String code;
  final String message;
  final Map<String, dynamic>? details;

  /// Name of the field that failed validation (if any).
  String? get field => details?['field'] as String?;
}
