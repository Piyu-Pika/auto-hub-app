import 'package:auto_hub_app/core/errors/exceptions.dart';
import 'package:auto_hub_app/core/network/api_endpoints.dart';
import 'package:auto_hub_app/features/help_center/models/help_article.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

abstract interface class HelpRemoteDatasource {
  Future<List<String>> getCategories();
  Future<List<HelpArticle>> getArticles({String? category, String? query});
  Future<Map<String, dynamic>> createTicket({
    required String category,
    required String subject,
    required String description,
    String? orderId,
    List<String>? attachments,
  });
  Future<Map<String, dynamic>> requestCallback({
    required String phone,
    String? preferredTime,
  });
}

@LazySingleton(as: HelpRemoteDatasource)
class HelpRemoteDatasourceImpl implements HelpRemoteDatasource {
  HelpRemoteDatasourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<List<String>> getCategories() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        ApiEndpoints.helpCategories,
      );

      final envelope = response.data;
      if (envelope != null && envelope['data'] is List) {
        return (envelope['data'] as List)
            .map((e) => (e is Map ? e['name']?.toString() : e.toString()) ?? '')
            .where((name) => name.isNotEmpty)
            .toList();
      }
      return <String>[];
    } on DioException catch (e) {
      if (e.error is ServerException) throw e.error!;
      throw ServerException(
        message: e.message ?? 'Failed to load help categories.',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<List<HelpArticle>> getArticles({String? category, String? query}) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        ApiEndpoints.helpArticles,
        queryParameters: {
          if (category != null && category != 'All') 'category': category,
          if (query != null && query.isNotEmpty) 'q': query,
        },
      );

      final envelope = response.data;
      if (envelope != null && envelope['data'] is List) {
        return (envelope['data'] as List)
            .map((e) => HelpArticle.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return <HelpArticle>[];
    } on DioException catch (e) {
      if (e.error is ServerException) throw e.error!;
      throw ServerException(
        message: e.message ?? 'Failed to load articles.',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<Map<String, dynamic>> createTicket({
    required String category,
    required String subject,
    required String description,
    String? orderId,
    List<String>? attachments,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.supportTickets,
        data: {
          'category': category,
          'subject': subject,
          'description': description,
          if (orderId != null) 'orderId': orderId,
          if (attachments != null) 'attachments': attachments,
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
        message: e.message ?? 'Failed to submit support ticket.',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<Map<String, dynamic>> requestCallback({
    required String phone,
    String? preferredTime,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.supportCallback,
        data: {
          'phone': phone,
          if (preferredTime != null) 'preferredTime': preferredTime,
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
        message: e.message ?? 'Failed to request callback.',
        statusCode: e.response?.statusCode,
      );
    }
  }
}

