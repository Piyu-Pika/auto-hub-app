import 'package:auto_hub_app/core/errors/exceptions.dart';
import 'package:auto_hub_app/core/network/api_endpoints.dart';
import 'package:auto_hub_app/core/network/api_response.dart';
import 'package:auto_hub_app/features/browse/domain/models/product_part_item.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

abstract interface class BrowseRemoteDatasource {
  Future<ApiResponse<List<ProductPartItem>>> getParts({
    String? query,
    List<String>? makes,
    List<String>? categories,
    List<String>? conditions,
    double? minPrice,
    double? maxPrice,
    String? vin,
    bool? featured,
    String? sort,
    int page = 1,
    int limit = 20,
  });

  Future<Map<String, dynamic>> getFilterOptions({
    String? query,
    List<String>? makes,
    List<String>? categories,
    List<String>? conditions,
    double? minPrice,
    double? maxPrice,
    String? vin,
  });

  Future<Map<String, dynamic>> getPartDetail(String id);

  Future<List<ProductPartItem>> getSimilarParts(String id, {int limit = 10});

  Future<bool> toggleFavorite(String id);

  Future<List<ProductPartItem>> getSavedParts({int page = 1, int limit = 20});

  Future<void> removeSavedPart(String partId);
}

@LazySingleton(as: BrowseRemoteDatasource)
class BrowseRemoteDatasourceImpl implements BrowseRemoteDatasource {
  BrowseRemoteDatasourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<ApiResponse<List<ProductPartItem>>> getParts({
    String? query,
    List<String>? makes,
    List<String>? categories,
    List<String>? conditions,
    double? minPrice,
    double? maxPrice,
    String? vin,
    bool? featured,
    String? sort,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
        if (query != null && query.isNotEmpty) 'q': query,
        if (makes != null && makes.isNotEmpty && !makes.contains('All Makes'))
          'make': makes,
        if (categories != null &&
            categories.isNotEmpty &&
            !categories.contains('All Categories'))
          'category': categories,
        if (conditions != null &&
            conditions.isNotEmpty &&
            !conditions.contains('All'))
          'condition': conditions,
        if (minPrice != null) 'minPrice': minPrice,
        if (maxPrice != null) 'maxPrice': maxPrice,
        if (vin != null && vin.isNotEmpty) 'vin': vin,
        if (featured == true) 'featured': 'true',
        if (sort != null && sort.isNotEmpty) 'sort': sort,
      };

      final response = await _dio.get<Map<String, dynamic>>(
        ApiEndpoints.parts,
        queryParameters: queryParams,
      );

      return ApiResponse<List<ProductPartItem>>.fromJson(
        response.data ?? <String, dynamic>{},
        (dynamic json) {
          if (json is List) {
            return json
                .map((e) => ProductPartItem.fromJson(e as Map<String, dynamic>))
                .toList();
          }
          return <ProductPartItem>[];
        },
      );
    } on DioException catch (e) {
      if (e.error is ServerException) throw e.error!;
      throw ServerException(
        message: e.message ?? 'Failed to load parts.',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<Map<String, dynamic>> getFilterOptions({
    String? query,
    List<String>? makes,
    List<String>? categories,
    List<String>? conditions,
    double? minPrice,
    double? maxPrice,
    String? vin,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        if (query != null && query.isNotEmpty) 'q': query,
        if (makes != null && makes.isNotEmpty && !makes.contains('All Makes'))
          'make': makes,
        if (categories != null &&
            categories.isNotEmpty &&
            !categories.contains('All Categories'))
          'category': categories,
        if (conditions != null &&
            conditions.isNotEmpty &&
            !conditions.contains('All'))
          'condition': conditions,
        if (minPrice != null) 'minPrice': minPrice,
        if (maxPrice != null) 'maxPrice': maxPrice,
        if (vin != null && vin.isNotEmpty) 'vin': vin,
      };

      final response = await _dio.get<Map<String, dynamic>>(
        ApiEndpoints.partsFilterOptions,
        queryParameters: queryParams,
      );

      final envelope = response.data;
      if (envelope != null && envelope['data'] is Map<String, dynamic>) {
        return envelope['data'] as Map<String, dynamic>;
      }
      return <String, dynamic>{};
    } on DioException catch (e) {
      if (e.error is ServerException) throw e.error!;
      throw ServerException(
        message: e.message ?? 'Failed to load filter options.',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<Map<String, dynamic>> getPartDetail(String id) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        ApiEndpoints.partById(id),
      );

      final envelope = response.data;
      if (envelope != null && envelope['data'] is Map<String, dynamic>) {
        return envelope['data'] as Map<String, dynamic>;
      }
      throw const ServerException(message: 'Part details not found.');
    } on DioException catch (e) {
      if (e.error is ServerException) throw e.error!;
      throw ServerException(
        message: e.message ?? 'Failed to load part details.',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<List<ProductPartItem>> getSimilarParts(
    String id, {
    int limit = 10,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        ApiEndpoints.partSimilar(id),
        queryParameters: {'limit': limit},
      );

      final envelope = response.data;
      if (envelope != null && envelope['data'] is List) {
        return (envelope['data'] as List)
            .map((e) => ProductPartItem.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return <ProductPartItem>[];
    } on DioException catch (e) {
      if (e.error is ServerException) throw e.error!;
      throw ServerException(
        message: e.message ?? 'Failed to load similar parts.',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<bool> toggleFavorite(String id) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.partFavorite(id),
        data: <String, dynamic>{},
      );

      final envelope = response.data;
      final data = envelope?['data'] as Map<String, dynamic>?;
      return data?['isFavorite'] as bool? ?? false;
    } on DioException catch (e) {
      if (e.error is ServerException) throw e.error!;
      throw ServerException(
        message: e.message ?? 'Failed to update favorite status.',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<List<ProductPartItem>> getSavedParts({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        ApiEndpoints.savedParts,
        queryParameters: {'page': page, 'limit': limit},
      );

      final envelope = response.data;
      if (envelope != null && envelope['data'] is List) {
        return (envelope['data'] as List)
            .map((e) => ProductPartItem.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return <ProductPartItem>[];
    } on DioException catch (e) {
      if (e.error is ServerException) throw e.error!;
      throw ServerException(
        message: e.message ?? 'Failed to load saved parts.',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<void> removeSavedPart(String partId) async {
    try {
      await _dio.delete<Map<String, dynamic>>(
        ApiEndpoints.savedPartById(partId),
      );
    } on DioException catch (e) {
      if (e.error is ServerException) throw e.error!;
    }
  }
}
