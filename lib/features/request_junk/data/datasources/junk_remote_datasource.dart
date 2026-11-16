import 'package:auto_hub_app/core/errors/exceptions.dart';
import 'package:auto_hub_app/core/network/api_endpoints.dart';
import 'package:auto_hub_app/features/request_junk/models/junk_models.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

abstract interface class JunkRemoteDatasource {
  Future<Map<String, dynamic>> getInstantQuote({
    required String year,
    required String make,
    required String model,
    required String condition,
    required bool hasTitle,
    required bool hasKeys,
    String? vin,
  });

  Future<List<String>> uploadVehicleImages(List<String> filePaths);

  Future<JunkRequest> createJunkRequest({
    required String year,
    required String make,
    required String model,
    required String condition,
    required bool hasTitle,
    required bool hasKeys,
    required String pickupAddress,
    String? vin,
    String? notes,
    List<String>? imageUrls,
  });

  Future<List<JunkRequest>> getJunkRequests({
    String status = 'all',
    int page = 1,
    int limit = 20,
  });

  Future<JunkRequest> getJunkRequestById(String id);

  Future<JunkRequest> acceptOffer(String id, {required int offerAmount});

  Future<JunkRequest> schedulePickup(String id, {required String scheduledAt, String? notes});

  Future<JunkRequest> cancelJunkRequest(String id, {String? reason});
}

@LazySingleton(as: JunkRemoteDatasource)
class JunkRemoteDatasourceImpl implements JunkRemoteDatasource {
  JunkRemoteDatasourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<Map<String, dynamic>> getInstantQuote({
    required String year,
    required String make,
    required String model,
    required String condition,
    required bool hasTitle,
    required bool hasKeys,
    String? vin,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.junkQuote,
        data: {
          'year': year,
          'make': make,
          'model': model,
          'condition': condition,
          'hasTitle': hasTitle,
          'hasKeys': hasKeys,
          'vin': vin ?? '',
        },
      );

      final envelope = response.data;
      if (envelope != null && envelope['data'] is Map<String, dynamic>) {
        return envelope['data'] as Map<String, dynamic>;
      }
      return <String, dynamic>{};
    } on DioException catch (e) {
      if (e.error is ServerException) throw e.error!;
      throw ServerException(
        message: e.message ?? 'Failed to get instant quote.',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<List<String>> uploadVehicleImages(List<String> filePaths) async {
    try {
      final formData = FormData();
      for (final path in filePaths) {
        formData.files.add(
          MapEntry(
            'files[]',
            await MultipartFile.fromFile(path),
          ),
        );
      }

      final response = await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.uploadVehicleImages,
        data: formData,
      );

      final envelope = response.data;
      final urls = envelope?['data']?['urls'] as List?;
      if (urls != null) {
        return urls.map((e) => e.toString()).toList();
      }
      return <String>[];
    } on DioException catch (e) {
      if (e.error is ServerException) throw e.error!;
      throw ServerException(
        message: e.message ?? 'Failed to upload vehicle images.',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<JunkRequest> createJunkRequest({
    required String year,
    required String make,
    required String model,
    required String condition,
    required bool hasTitle,
    required bool hasKeys,
    required String pickupAddress,
    String? vin,
    String? notes,
    List<String>? imageUrls,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.junkRequests,
        data: {
          'year': year,
          'make': make,
          'model': model,
          'condition': condition,
          'hasTitle': hasTitle,
          'hasKeys': hasKeys,
          'pickupAddress': pickupAddress,
          'vin': vin ?? '',
          if (notes != null) 'notes': notes,
          if (imageUrls != null) 'imageUrls': imageUrls,
        },
      );

      final envelope = response.data;
      if (envelope != null && envelope['data'] is Map<String, dynamic>) {
        return JunkRequest.fromJson(envelope['data'] as Map<String, dynamic>);
      }
      throw const ServerException(message: 'Failed to create junk request.');
    } on DioException catch (e) {
      if (e.error is ServerException) throw e.error!;
      throw ServerException(
        message: e.message ?? 'Failed to submit junk request.',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<List<JunkRequest>> getJunkRequests({
    String status = 'all',
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        ApiEndpoints.junkRequests,
        queryParameters: {'status': status, 'page': page, 'limit': limit},
      );

      final envelope = response.data;
      if (envelope != null && envelope['data'] is List) {
        return (envelope['data'] as List)
            .map((e) => JunkRequest.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return <JunkRequest>[];
    } on DioException catch (e) {
      if (e.error is ServerException) throw e.error!;
      throw ServerException(
        message: e.message ?? 'Failed to load junk requests.',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<JunkRequest> getJunkRequestById(String id) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        ApiEndpoints.junkRequestById(id),
      );

      final envelope = response.data;
      if (envelope != null && envelope['data'] is Map<String, dynamic>) {
        return JunkRequest.fromJson(envelope['data'] as Map<String, dynamic>);
      }
      throw const ServerException(message: 'Junk request not found.');
    } on DioException catch (e) {
      if (e.error is ServerException) throw e.error!;
      throw ServerException(
        message: e.message ?? 'Failed to load request details.',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<JunkRequest> acceptOffer(String id, {required int offerAmount}) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.junkRequestAcceptOffer(id),
        data: {'offerAmount': offerAmount},
      );

      final envelope = response.data;
      if (envelope != null && envelope['data'] is Map<String, dynamic>) {
        return JunkRequest.fromJson(envelope['data'] as Map<String, dynamic>);
      }
      throw const ServerException(message: 'Failed to accept offer.');
    } on DioException catch (e) {
      if (e.error is ServerException) throw e.error!;
      throw ServerException(
        message: e.message ?? 'Failed to accept offer.',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<JunkRequest> schedulePickup(
    String id, {
    required String scheduledAt,
    String? notes,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.junkRequestPickupSchedule(id),
        data: {
          'scheduledAt': scheduledAt,
          if (notes != null) 'notes': notes,
        },
      );

      final envelope = response.data;
      if (envelope != null && envelope['data'] is Map<String, dynamic>) {
        return JunkRequest.fromJson(envelope['data'] as Map<String, dynamic>);
      }
      throw const ServerException(message: 'Failed to schedule pickup.');
    } on DioException catch (e) {
      if (e.error is ServerException) throw e.error!;
      throw ServerException(
        message: e.message ?? 'Failed to schedule pickup.',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<JunkRequest> cancelJunkRequest(String id, {String? reason}) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.junkRequestCancel(id),
        data: {
          if (reason != null) 'reason': reason,
        },
      );

      final envelope = response.data;
      if (envelope != null && envelope['data'] is Map<String, dynamic>) {
        return JunkRequest.fromJson(envelope['data'] as Map<String, dynamic>);
      }
      throw const ServerException(message: 'Failed to cancel junk request.');
    } on DioException catch (e) {
      if (e.error is ServerException) throw e.error!;
      throw ServerException(
        message: e.message ?? 'Failed to cancel request.',
        statusCode: e.response?.statusCode,
      );
    }
  }
}

