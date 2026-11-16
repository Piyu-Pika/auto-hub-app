import 'package:auto_hub_app/core/errors/exceptions.dart';
import 'package:auto_hub_app/core/network/api_endpoints.dart';
import 'package:auto_hub_app/features/settings/domain/models/app_settings.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

abstract interface class SettingsRemoteDatasource {
  Future<AppSettings> getSettings();
  Future<AppSettings> updateSettings(Map<String, dynamic> changedKeys);
  Future<List<Map<String, dynamic>>> getLanguages();
  Future<void> requestAccountDeletion({required String reason, required String confirmationText});
}

@LazySingleton(as: SettingsRemoteDatasource)
class SettingsRemoteDatasourceImpl implements SettingsRemoteDatasource {
  SettingsRemoteDatasourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<AppSettings> getSettings() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        ApiEndpoints.settings,
      );

      final envelope = response.data;
      if (envelope != null && envelope['data'] is Map<String, dynamic>) {
        return AppSettings.fromJson(envelope['data'] as Map<String, dynamic>);
      }
      return const AppSettings();
    } on DioException catch (e) {
      if (e.error is ServerException) throw e.error!;
      throw ServerException(
        message: e.message ?? 'Failed to load settings.',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<AppSettings> updateSettings(Map<String, dynamic> changedKeys) async {
    try {
      final response = await _dio.patch<Map<String, dynamic>>(
        ApiEndpoints.settings,
        data: changedKeys,
      );

      final envelope = response.data;
      if (envelope != null && envelope['data'] is Map<String, dynamic>) {
        return AppSettings.fromJson(envelope['data'] as Map<String, dynamic>);
      }
      throw const ServerException(message: 'Failed to update settings.');
    } on DioException catch (e) {
      if (e.error is ServerException) throw e.error!;
      throw ServerException(
        message: e.message ?? 'Failed to update settings.',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getLanguages() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        ApiEndpoints.settingsLanguages,
      );

      final envelope = response.data;
      if (envelope != null && envelope['data'] is List) {
        return (envelope['data'] as List)
            .cast<Map<String, dynamic>>();
      }
      return const [
        {'code': 'en', 'name': 'English', 'flag': '🇺🇸'},
        {'code': 'es', 'name': 'Español', 'flag': '🇲🇽'},
      ];
    } catch (_) {
      return const [
        {'code': 'en', 'name': 'English', 'flag': '🇺🇸'},
        {'code': 'es', 'name': 'Español', 'flag': '🇲🇽'},
      ];
    }
  }

  @override
  Future<void> requestAccountDeletion({
    required String reason,
    required String confirmationText,
  }) async {
    try {
      await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.userDeletion,
        data: {
          'reason': reason,
          'confirmationText': confirmationText,
        },
      );
    } on DioException catch (e) {
      if (e.error is ServerException) throw e.error!;
      throw ServerException(
        message: e.message ?? 'Failed to request account deletion.',
        statusCode: e.response?.statusCode,
      );
    }
  }
}

