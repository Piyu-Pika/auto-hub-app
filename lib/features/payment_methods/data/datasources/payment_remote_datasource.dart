import 'package:auto_hub_app/core/errors/exceptions.dart';
import 'package:auto_hub_app/core/network/api_endpoints.dart';
import 'package:auto_hub_app/features/payment_methods/domain/entities/payment_card.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

abstract interface class PaymentRemoteDatasource {
  Future<List<PaymentCard>> getPaymentMethods();
  Future<PaymentCard> addPaymentMethod({
    required String cardHolder,
    required String cardNumber,
    required String expiry,
    required String cvc,
    bool makeDefault = false,
  });
  Future<void> removePaymentMethod(String cardId);
  Future<PaymentCard> setDefaultPaymentMethod(String cardId);
}

@LazySingleton(as: PaymentRemoteDatasource)
class PaymentRemoteDatasourceImpl implements PaymentRemoteDatasource {
  PaymentRemoteDatasourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<List<PaymentCard>> getPaymentMethods() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        ApiEndpoints.paymentMethods,
      );

      final envelope = response.data;
      if (envelope != null && envelope['data'] is List) {
        return (envelope['data'] as List)
            .map((e) => PaymentCard.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return <PaymentCard>[];
    } on DioException catch (e) {
      if (e.error is ServerException) throw e.error!;
      throw ServerException(
        message: e.message ?? 'Failed to load payment methods.',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<PaymentCard> addPaymentMethod({
    required String cardHolder,
    required String cardNumber,
    required String expiry,
    required String cvc,
    bool makeDefault = false,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.paymentMethods,
        data: {
          'cardHolder': cardHolder,
          'cardNumber': cardNumber,
          'expiry': expiry,
          'cvc': cvc,
          'makeDefault': makeDefault,
        },
      );

      final envelope = response.data;
      if (envelope != null && envelope['data'] is Map<String, dynamic>) {
        return PaymentCard.fromJson(envelope['data'] as Map<String, dynamic>);
      }
      throw const ServerException(message: 'Failed to add card.');
    } on DioException catch (e) {
      if (e.error is ServerException) throw e.error!;
      throw ServerException(
        message: e.message ?? 'Failed to add payment card.',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<void> removePaymentMethod(String cardId) async {
    try {
      await _dio.delete<Map<String, dynamic>>(
        ApiEndpoints.paymentMethodById(cardId),
      );
    } on DioException catch (e) {
      if (e.error is ServerException) throw e.error!;
      throw ServerException(
        message: e.message ?? 'Failed to remove payment method.',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<PaymentCard> setDefaultPaymentMethod(String cardId) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.paymentMethodDefault(cardId),
      );

      final envelope = response.data;
      if (envelope != null && envelope['data'] is Map<String, dynamic>) {
        return PaymentCard.fromJson(envelope['data'] as Map<String, dynamic>);
      }
      throw const ServerException(message: 'Failed to set default card.');
    } on DioException catch (e) {
      if (e.error is ServerException) throw e.error!;
      throw ServerException(
        message: e.message ?? 'Failed to set default card.',
        statusCode: e.response?.statusCode,
      );
    }
  }
}

