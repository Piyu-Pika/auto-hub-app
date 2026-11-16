import 'package:auto_hub_app/core/errors/exceptions.dart';
import 'package:auto_hub_app/core/network/api_endpoints.dart';
import 'package:auto_hub_app/features/my_order/domain/models/order_model.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart' hide Order;

abstract interface class OrderRemoteDatasource {
  Future<List<Order>> getOrders({String status = 'all', int page = 1, int limit = 20});
  Future<Order> getOrderById(String id);
  Future<Order> cancelOrder(String id, {required String reason, String? note});
  Future<Map<String, dynamic>> getOrderTracking(String id);
  Future<void> rateOrder(String id, {required int rating, String? comment});
  Future<void> returnOrder(String id, {required String reason, String? note, List<String>? images});
}

@LazySingleton(as: OrderRemoteDatasource)
class OrderRemoteDatasourceImpl implements OrderRemoteDatasource {
  OrderRemoteDatasourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<List<Order>> getOrders({
    String status = 'all',
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        ApiEndpoints.orders,
        queryParameters: {
          'status': status,
          'page': page,
          'limit': limit,
        },
      );

      final envelope = response.data;
      if (envelope != null && envelope['data'] is List) {
        return (envelope['data'] as List)
            .map((e) => Order.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return <Order>[];
    } on DioException catch (e) {
      if (e.error is ServerException) throw e.error!;
      throw ServerException(
        message: e.message ?? 'Failed to load orders.',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<Order> getOrderById(String id) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        ApiEndpoints.orderById(id),
      );

      final envelope = response.data;
      if (envelope != null && envelope['data'] is Map<String, dynamic>) {
        return Order.fromJson(envelope['data'] as Map<String, dynamic>);
      }
      throw const ServerException(message: 'Order not found.');
    } on DioException catch (e) {
      if (e.error is ServerException) throw e.error!;
      throw ServerException(
        message: e.message ?? 'Failed to load order details.',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<Order> cancelOrder(
    String id, {
    required String reason,
    String? note,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.orderCancel(id),
        data: {
          'reason': reason,
          if (note != null) 'note': note,
        },
      );

      final envelope = response.data;
      if (envelope != null && envelope['data'] is Map<String, dynamic>) {
        return Order.fromJson(envelope['data'] as Map<String, dynamic>);
      }
      throw const ServerException(message: 'Failed to cancel order.');
    } on DioException catch (e) {
      if (e.error is ServerException) throw e.error!;
      throw ServerException(
        message: e.message ?? 'Failed to cancel order.',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<Map<String, dynamic>> getOrderTracking(String id) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        ApiEndpoints.orderTracking(id),
      );

      final envelope = response.data;
      if (envelope != null && envelope['data'] is Map<String, dynamic>) {
        return envelope['data'] as Map<String, dynamic>;
      }
      return <String, dynamic>{};
    } on DioException catch (e) {
      if (e.error is ServerException) throw e.error!;
      throw ServerException(
        message: e.message ?? 'Failed to load tracking information.',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<void> rateOrder(
    String id, {
    required int rating,
    String? comment,
  }) async {
    try {
      await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.orderRate(id),
        data: {
          'rating': rating,
          if (comment != null) 'comment': comment,
        },
      );
    } on DioException catch (e) {
      if (e.error is ServerException) throw e.error!;
      throw ServerException(
        message: e.message ?? 'Failed to submit review.',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<void> returnOrder(
    String id, {
    required String reason,
    String? note,
    List<String>? images,
  }) async {
    try {
      await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.orderReturn(id),
        data: {
          'reason': reason,
          if (note != null) 'note': note,
          if (images != null) 'images': images,
        },
      );
    } on DioException catch (e) {
      if (e.error is ServerException) throw e.error!;
      throw ServerException(
        message: e.message ?? 'Failed to request return.',
        statusCode: e.response?.statusCode,
      );
    }
  }
}

