import 'dart:io';
import 'package:auto_hub_app/core/errors/exceptions.dart';
import 'package:auto_hub_app/core/network/api_endpoints.dart';
import 'package:auto_hub_app/features/account_details/domain/models/user_profile.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

abstract interface class AccountRemoteDatasource {
  Future<UserProfile> getUserProfile();
  Future<UserProfile> updateUserProfile({
    String? fullName,
    String? phone,
    String? location,
  });
  Future<String> uploadAvatar(File file);
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  });
  Future<void> clearSearchHistory();
}

@LazySingleton(as: AccountRemoteDatasource)
class AccountRemoteDatasourceImpl implements AccountRemoteDatasource {
  AccountRemoteDatasourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<UserProfile> getUserProfile() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        ApiEndpoints.userMe,
      );

      final envelope = response.data;
      if (envelope != null && envelope['data'] is Map<String, dynamic>) {
        return UserProfile.fromJson(envelope['data'] as Map<String, dynamic>);
      }
      throw const ServerException(message: 'Profile not found.');
    } on DioException catch (e) {
      if (e.error is ServerException) throw e.error!;
      throw ServerException(
        message: e.message ?? 'Failed to load profile.',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<UserProfile> updateUserProfile({
    String? fullName,
    String? phone,
    String? location,
  }) async {
    try {
      final response = await _dio.patch<Map<String, dynamic>>(
        ApiEndpoints.userMe,
        data: {
          if (fullName != null) 'fullName': fullName,
          if (phone != null) 'phone': phone,
          if (location != null) 'location': location,
        },
      );

      final envelope = response.data;
      if (envelope != null && envelope['data'] is Map<String, dynamic>) {
        return UserProfile.fromJson(envelope['data'] as Map<String, dynamic>);
      }
      throw const ServerException(message: 'Failed to update profile.');
    } on DioException catch (e) {
      if (e.error is ServerException) throw e.error!;
      throw ServerException(
        message: e.message ?? 'Failed to update profile.',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<String> uploadAvatar(File file) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(file.path),
      });

      final response = await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.userAvatar,
        data: formData,
      );

      final envelope = response.data;
      final data = envelope?['data'] as Map<String, dynamic>?;
      return data?['avatarUrl'] as String? ?? '';
    } on DioException catch (e) {
      if (e.error is ServerException) throw e.error!;
      throw ServerException(
        message: e.message ?? 'Failed to upload avatar.',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.userPassword,
        data: {
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        },
      );
    } on DioException catch (e) {
      if (e.error is ServerException) throw e.error!;
      throw ServerException(
        message: e.message ?? 'Failed to update password.',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<void> clearSearchHistory() async {
    try {
      await _dio.delete<Map<String, dynamic>>(
        ApiEndpoints.userSearchHistory,
      );
    } on DioException catch (e) {
      if (e.error is ServerException) throw e.error!;
    }
  }
}

