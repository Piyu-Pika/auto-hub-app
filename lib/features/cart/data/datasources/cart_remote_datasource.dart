import 'package:auto_hub_app/core/errors/exceptions.dart';
import 'package:auto_hub_app/core/network/api_endpoints.dart';
import 'package:auto_hub_app/features/cart/domain/entities/cart.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

abstract interface class CartRemoteDatasource {
  Future<Cart> getCart();
  Future<Cart> addItem({required String partId, int quantity = 1});
  Future<Cart> updateItemQuantity({required String cartItemId, required int quantity});
  Future<Cart> removeItem(String cartItemId);
  Future<Map<String, dynamic>> checkout({
    required String addressId,
    required String paymentMethodId,
    String shippingMethod = 'standard',
    String? couponCode,
  });
}

@LazySingleton(as: CartRemoteDatasource)
class CartRemoteDatasourceImpl implements CartRemoteDatasource {
  CartRemoteDatasourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<Cart> getCart() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        ApiEndpoints.cart,
      );

      final envelope = response.data;
      if (envelope != null && envelope['data'] is Map<String, dynamic>) {
        return Cart.fromJson(envelope['data'] as Map<String, dynamic>);
      }
      return const Cart(cartId: '', items: [], subtotal: 0, shipping: 0, tax: 0, total: 0);
    } on DioException catch (e) {
      if (e.error is ServerException) throw e.error!;
      throw ServerException(
        message: e.message ?? 'Failed to load cart.',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<Cart> addItem({required String partId, int quantity = 1}) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.cartItems,
        data: {
          'partId': partId,
          'quantity': quantity,
        },
      );

      final envelope = response.data;
      if (envelope != null && envelope['data'] is Map<String, dynamic>) {
        return Cart.fromJson(envelope['data'] as Map<String, dynamic>);
      }
      throw const ServerException(message: 'Failed to add item to cart.');
    } on DioException catch (e) {
      if (e.error is ServerException) throw e.error!;
      throw ServerException(
        message: e.message ?? 'Failed to add item to cart.',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<Cart> updateItemQuantity({
    required String cartItemId,
    required int quantity,
  }) async {
    try {
      final response = await _dio.patch<Map<String, dynamic>>(
        ApiEndpoints.cartItemById(cartItemId),
        data: {'quantity': quantity},
      );

      final envelope = response.data;
      if (envelope != null && envelope['data'] is Map<String, dynamic>) {
        return Cart.fromJson(envelope['data'] as Map<String, dynamic>);
      }
      throw const ServerException(message: 'Failed to update item quantity.');
    } on DioException catch (e) {
      if (e.error is ServerException) throw e.error!;
      throw ServerException(
        message: e.message ?? 'Failed to update quantity.',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<Cart> removeItem(String cartItemId) async {
    try {
      final response = await _dio.delete<Map<String, dynamic>>(
        ApiEndpoints.cartItemById(cartItemId),
      );

      final envelope = response.data;
      if (envelope != null && envelope['data'] is Map<String, dynamic>) {
        return Cart.fromJson(envelope['data'] as Map<String, dynamic>);
      }
      return const Cart(cartId: '', items: [], subtotal: 0, shipping: 0, tax: 0, total: 0);
    } on DioException catch (e) {
      if (e.error is ServerException) throw e.error!;
      throw ServerException(
        message: e.message ?? 'Failed to remove cart item.',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<Map<String, dynamic>> checkout({
    required String addressId,
    required String paymentMethodId,
    String shippingMethod = 'standard',
    String? couponCode,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.checkoutOrders,
        data: {
          'addressId': addressId,
          'paymentMethodId': paymentMethodId,
          'shippingMethod': shippingMethod,
          'couponCode': couponCode,
        },
      );

      final envelope = response.data;
      if (envelope != null && envelope['data'] is Map<String, dynamic>) {
        return envelope['data'] as Map<String, dynamic>;
      }
      throw const ServerException(message: 'Checkout failed.');
    } on DioException catch (e) {
      if (e.error is ServerException) throw e.error!;
      throw ServerException(
        message: e.message ?? 'Failed to complete order.',
        statusCode: e.response?.statusCode,
      );
    }
  }
}

