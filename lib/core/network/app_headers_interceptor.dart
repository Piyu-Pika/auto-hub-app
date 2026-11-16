import 'dart:io';
import 'dart:math';
import 'package:dio/dio.dart';

/// Interceptor that attaches standard AutoHub headers to every outgoing request.
class AppHeadersInterceptor extends Interceptor {
  AppHeadersInterceptor({
    String? deviceId,
    String? appVersion,
    String? locale,
    String? timezone,
  })  : _deviceId = deviceId ?? _generateDeviceId(),
        _appVersion = appVersion ?? '1.0.0+1',
        _locale = locale ?? 'en-us',
        _timezone = timezone ?? _getSystemTimezone();

  final String _deviceId;
  final String _appVersion;
  final String _locale;
  final String _timezone;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers['Accept'] = 'application/json';

    // Set Content-Type only if not multipart
    if (options.data is! FormData) {
      options.headers['Content-Type'] = 'application/json';
    }

    // Attach tracking and platform metadata
    options.headers['X-Request-Id'] ??= _generateUuid();
    options.headers['X-App-Platform'] = Platform.isIOS ? 'ios' : 'android';
    options.headers['X-App-Version'] = _appVersion;
    options.headers['X-Device-Id'] = _deviceId;
    options.headers['X-Locale'] = _locale;
    options.headers['X-Timezone'] = _timezone;

    handler.next(options);
  }

  static String _generateUuid() {
    final random = Random.secure();
    final values = List<int>.generate(16, (i) => random.nextInt(256));
    values[6] = (values[6] & 0x0f) | 0x40; // Version 4
    values[8] = (values[8] & 0x3f) | 0x80; // Variant 10
    final hex = values.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-'
        '${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20)}';
  }

  static String _generateDeviceId() {
    final random = Random.secure();
    final values = List<int>.generate(16, (i) => random.nextInt(256));
    return values.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }

  static String _getSystemTimezone() {
    try {
      return DateTime.now().timeZoneName;
    } catch (_) {
      return 'UTC';
    }
  }
}
