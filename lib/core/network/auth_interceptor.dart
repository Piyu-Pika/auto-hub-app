import 'dart:async';
import 'package:auto_hub_app/core/network/api_endpoints.dart';
import 'package:auto_hub_app/core/network/token_storage.dart';
import 'package:dio/dio.dart';

/// Interceptor that attaches JWT Bearer token and handles transparent 401 token refresh.
class AuthInterceptor extends QueuedInterceptor {
  AuthInterceptor({
    required TokenStorage tokenStorage,
    required Dio dio,
  })  : _tokenStorage = tokenStorage,
        _dio = dio;

  final TokenStorage _tokenStorage;
  final Dio _dio;

  Completer<bool>? _refreshCompleter;

  static const List<String> _publicEndpoints = [
    ApiEndpoints.register,
    ApiEndpoints.login,
    ApiEndpoints.refresh,
    ApiEndpoints.forgotPassword,
    ApiEndpoints.resetPassword,
    ApiEndpoints.social,
    ApiEndpoints.referralsTrack,
  ];

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final isPublic = _publicEndpoints.any((p) => options.path.contains(p));
    final token = _tokenStorage.accessToken;

    if (!isPublic && token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final response = err.response;
    final is401 = response?.statusCode == 401;
    final isRefreshCall = err.requestOptions.path.contains(ApiEndpoints.refresh);

    // If it's a 401 and not the refresh endpoint itself
    if (is401 && !isRefreshCall && _tokenStorage.refreshToken != null) {
      final success = await _refreshToken();
      if (success) {
        // Retry the original request with the new access token
        final options = err.requestOptions;
        options.headers['Authorization'] = 'Bearer ${_tokenStorage.accessToken}';

        try {
          final retryResponse = await _dio.fetch<dynamic>(options);
          return handler.resolve(retryResponse);
        } on DioException catch (retryErr) {
          return handler.next(retryErr);
        }
      } else {
        await _tokenStorage.clearTokens();
      }
    }

    handler.next(err);
  }

  Future<bool> _refreshToken() async {
    // If a refresh is already in-flight, await its completion
    if (_refreshCompleter != null) {
      return _refreshCompleter!.future;
    }

    _refreshCompleter = Completer<bool>();

    try {
      final currentRefreshToken = _tokenStorage.refreshToken;
      if (currentRefreshToken == null) {
        _refreshCompleter!.complete(false);
        return false;
      }

      // We make a fresh Dio call to avoid interceptor recursion
      final refreshResponse = await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.refresh,
        data: {'refreshToken': currentRefreshToken},
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );

      final data = refreshResponse.data?['data'] as Map<String, dynamic>?;
      if (data != null && data.containsKey('accessToken')) {
        final newAccessToken = data['accessToken'] as String;
        final newRefreshToken = data['refreshToken'] as String? ?? currentRefreshToken;

        await _tokenStorage.saveTokens(
          accessToken: newAccessToken,
          refreshToken: newRefreshToken,
        );

        _refreshCompleter!.complete(true);
        return true;
      }

      _refreshCompleter!.complete(false);
      return false;
    } catch (_) {
      _refreshCompleter!.complete(false);
      return false;
    } finally {
      _refreshCompleter = null;
    }
  }
}
