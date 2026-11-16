import 'package:auto_hub_app/core/errors/exceptions.dart';
import 'package:auto_hub_app/core/network/api_endpoints.dart';
import 'package:auto_hub_app/features/your_addresses/domain/entities/address.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

abstract interface class AddressRemoteDatasource {
  Future<List<Address>> getAddresses();
  Future<Address> createAddress(Address address);
  Future<Address> updateAddress(Address address);
  Future<void> deleteAddress(String id);
  Future<Address> setDefaultAddress(String id);
}

@LazySingleton(as: AddressRemoteDatasource)
class AddressRemoteDatasourceImpl implements AddressRemoteDatasource {
  AddressRemoteDatasourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<List<Address>> getAddresses() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        ApiEndpoints.addresses,
      );

      final envelope = response.data;
      if (envelope != null && envelope['data'] is List) {
        return (envelope['data'] as List)
            .map((e) => Address.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return <Address>[];
    } on DioException catch (e) {
      if (e.error is ServerException) throw e.error!;
      throw ServerException(
        message: e.message ?? 'Failed to load addresses.',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<Address> createAddress(Address address) async {
    try {
      final body = address.toJson()..remove('id');
      final response = await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.addresses,
        data: body,
      );

      final envelope = response.data;
      if (envelope != null && envelope['data'] is Map<String, dynamic>) {
        return Address.fromJson(envelope['data'] as Map<String, dynamic>);
      }
      throw const ServerException(message: 'Failed to create address.');
    } on DioException catch (e) {
      if (e.error is ServerException) throw e.error!;
      throw ServerException(
        message: e.message ?? 'Failed to add address.',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<Address> updateAddress(Address address) async {
    try {
      final body = address.toJson()..remove('id');
      final response = await _dio.patch<Map<String, dynamic>>(
        ApiEndpoints.addressById(address.id),
        data: body,
      );

      final envelope = response.data;
      if (envelope != null && envelope['data'] is Map<String, dynamic>) {
        return Address.fromJson(envelope['data'] as Map<String, dynamic>);
      }
      throw const ServerException(message: 'Failed to update address.');
    } on DioException catch (e) {
      if (e.error is ServerException) throw e.error!;
      throw ServerException(
        message: e.message ?? 'Failed to update address.',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<void> deleteAddress(String id) async {
    try {
      await _dio.delete<Map<String, dynamic>>(
        ApiEndpoints.addressById(id),
      );
    } on DioException catch (e) {
      if (e.error is ServerException) throw e.error!;
      throw ServerException(
        message: e.message ?? 'Failed to delete address.',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<Address> setDefaultAddress(String id) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.addressDefault(id),
      );

      final envelope = response.data;
      if (envelope != null && envelope['data'] is Map<String, dynamic>) {
        return Address.fromJson(envelope['data'] as Map<String, dynamic>);
      }
      throw const ServerException(message: 'Failed to set default address.');
    } on DioException catch (e) {
      if (e.error is ServerException) throw e.error!;
      throw ServerException(
        message: e.message ?? 'Failed to set default address.',
        statusCode: e.response?.statusCode,
      );
    }
  }
}

