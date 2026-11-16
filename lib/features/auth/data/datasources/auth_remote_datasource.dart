import 'package:auto_hub_app/core/errors/exceptions.dart';
import 'package:auto_hub_app/core/network/api_endpoints.dart';
import 'package:auto_hub_app/core/network/api_response.dart';
import 'package:auto_hub_app/features/auth/data/models/auth_response_model.dart';
import 'package:auto_hub_app/features/auth/data/models/user_model.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

abstract interface class AuthRemoteDatasource {
  Future<AuthResponseModel> register({
    required String fullName,
    required String email,
    required String password,
    String? phone,
    String? deviceId,
    String? platform,
  });

  Future<AuthResponseModel> login({
    required String email,
    required String password,
    String? deviceId,
  });

  Future<AuthResponseModel> socialAuth({
    required String provider,
    required String idToken,
    String? deviceId,
  });

  Future<UserModel> getSession();

  Future<void> logout(String? refreshToken);

  Future<String> forgotPassword(String email);

  Future<String> resetPassword({
    required String token,
    required String newPassword,
  });
}

@LazySingleton(as: AuthRemoteDatasource)
class AuthRemoteDatasourceImpl implements AuthRemoteDatasource {
  AuthRemoteDatasourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<AuthResponseModel> register({
    required String fullName,
    required String email,
    required String password,
    String? phone,
    String? deviceId,
    String? platform,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.register,
        data: {
          'fullName': fullName,
          'email': email,
          'password': password,
          if (phone != null && phone.isNotEmpty) 'phone': phone,
          if (deviceId != null) 'deviceId': deviceId,
          if (platform != null) 'platform': platform,
        },
      );

      final envelope = ApiResponse<AuthResponseModel>.fromJson(
        response.data ?? <String, dynamic>{},
        (dynamic json) =>
            AuthResponseModel.fromJson(json as Map<String, dynamic>),
      );

      return envelope.requireData;
    } on DioException catch (e) {
      if (e.error is ServerException) throw e.error!;
      throw ServerException(
        message: e.message ?? 'Registration failed. Please try again.',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<AuthResponseModel> login({
    required String email,
    required String password,
    String? deviceId,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.login,
        data: {
          'email': email,
          'password': password,
          if (deviceId != null) 'deviceId': deviceId,
        },
      );

      final envelope = ApiResponse<AuthResponseModel>.fromJson(
        response.data ?? <String, dynamic>{},
        (dynamic json) =>
            AuthResponseModel.fromJson(json as Map<String, dynamic>),
      );

      return envelope.requireData;
    } on DioException catch (e) {
      if (e.error is ServerException) throw e.error!;
      throw ServerException(
        message: e.message ?? 'Login failed. Please check your credentials.',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<AuthResponseModel> socialAuth({
    required String provider,
    required String idToken,
    String? deviceId,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.social,
        data: {
          'provider': provider,
          'idToken': idToken,
          if (deviceId != null) 'deviceId': deviceId,
        },
      );

      final envelope = ApiResponse<AuthResponseModel>.fromJson(
        response.data ?? <String, dynamic>{},
        (dynamic json) =>
            AuthResponseModel.fromJson(json as Map<String, dynamic>),
      );

      return envelope.requireData;
    } on DioException catch (e) {
      if (e.error is ServerException) throw e.error!;
      throw ServerException(
        message: e.message ?? 'Social login failed.',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<UserModel> getSession() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        ApiEndpoints.session,
      );

      final data = response.data?['data'] as Map<String, dynamic>?;
      final userJson = data?['user'] as Map<String, dynamic>?;
      if (userJson == null) {
        throw const ServerException(message: 'Invalid session data.');
      }

      return UserModel.fromJson(userJson);
    } on DioException catch (e) {
      if (e.error is ServerException) throw e.error!;
      throw ServerException(
        message: e.message ?? 'Session verification failed.',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<void> logout(String? refreshToken) async {
    try {
      await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.logout,
        data: {
          if (refreshToken != null) 'refreshToken': refreshToken,
        },
      );
    } on DioException catch (e) {
      if (e.error is ServerException) throw e.error!;
    }
  }

  @override
  Future<String> forgotPassword(String email) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.forgotPassword,
        data: {'email': email},
      );

      final data = response.data?['data'] as Map<String, dynamic>?;
      return data?['message'] as String? ??
          'If an account exists for this email, a reset link has been sent.';
    } on DioException catch (e) {
      if (e.error is ServerException) throw e.error!;
      throw ServerException(
        message: e.message ?? 'Unable to send reset password link.',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<String> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.resetPassword,
        data: {
          'token': token,
          'newPassword': newPassword,
        },
      );

      final data = response.data?['data'] as Map<String, dynamic>?;
      return data?['message'] as String? ?? 'Password updated successfully.';
    } on DioException catch (e) {
      if (e.error is ServerException) throw e.error!;
      throw ServerException(
        message: e.message ?? 'Failed to reset password.',
        statusCode: e.response?.statusCode,
      );
    }
  }
}
