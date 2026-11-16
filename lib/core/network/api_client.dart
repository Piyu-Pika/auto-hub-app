import 'package:auto_hub_app/core/constants/app_constants.dart';
import 'package:auto_hub_app/core/network/app_headers_interceptor.dart';
import 'package:auto_hub_app/core/network/auth_interceptor.dart';
import 'package:auto_hub_app/core/network/error_interceptor.dart';
import 'package:auto_hub_app/core/network/token_storage.dart';
import 'package:auto_hub_app/main.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:injectable/injectable.dart';

/// Network module that configures and provides [Dio] for dependency injection.
@module
abstract class NetworkModule {
  @lazySingleton
  Dio dio(TokenStorage tokenStorage) {
    var rawBaseUrl = dotenv.env[AppConstants.baseUrlKey] ?? 'https://api.autohubexpress.us';
    if (rawBaseUrl.endsWith('/')) {
      rawBaseUrl = rawBaseUrl.substring(0, rawBaseUrl.length - 1);
    }
    if (!rawBaseUrl.endsWith('/v1')) {
      rawBaseUrl = '$rawBaseUrl/v1';
    }

    final options = BaseOptions(
      baseUrl: rawBaseUrl,
      connectTimeout: const Duration(milliseconds: AppConstants.connectTimeoutMs),
      receiveTimeout: const Duration(milliseconds: AppConstants.receiveTimeoutMs),
      headers: {
        'Accept': 'application/json',
      },
    );

    final dio = Dio(options);

    // 1. App metadata headers (X-Request-Id, X-App-Version, etc.)
    dio.interceptors.add(AppHeadersInterceptor());

    // 2. Auth token injection and 401 refresh handler
    dio.interceptors.add(
      AuthInterceptor(
        tokenStorage: tokenStorage,
        dio: dio,
      ),
    );

    // 3. Error normalization interceptor
    dio.interceptors.add(ErrorInterceptor());

    // 4. Debug logger (never print())
    if (kDebugMode) {
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            final reqId = options.headers['X-Request-Id'];
            logger.d('HTTP Req [${options.method}] ${options.uri} (id: $reqId)');
            handler.next(options);
          },
          onResponse: (response, handler) {
            final reqId = response.requestOptions.headers['X-Request-Id'];
            logger.d('HTTP Res [${response.statusCode}] ${response.requestOptions.uri} (id: $reqId)');
            handler.next(response);
          },
          onError: (error, handler) {
            final reqId = error.requestOptions.headers['X-Request-Id'];
            logger.w(
              'HTTP Err [${error.response?.statusCode}] ${error.requestOptions.uri} (id: $reqId): ${error.message}',
            );
            handler.next(error);
          },
        ),
      );
    }

    return dio;
  }
}
