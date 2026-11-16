import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:injectable/injectable.dart';
import 'package:path_provider/path_provider.dart';

/// Contract for token and auth session persistence.
abstract interface class TokenStorage {
  String? get accessToken;
  String? get refreshToken;
  bool get isAuthenticated;
  bool get hasSeenOnboarding;

  Stream<bool> get authStateChanges;

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  });

  Future<void> clearTokens();

  Future<void> setHasSeenOnboarding({bool seen = true});
}

/// Persistent file-backed implementation of [TokenStorage].
@LazySingleton(as: TokenStorage)
class InMemoryTokenStorage implements TokenStorage {
  InMemoryTokenStorage() {
    _initFuture = _loadFromDisk();
  }

  static const String _fileName = 'auth_session.json';

  String? _accessToken;
  String? _refreshToken;
  bool _hasSeenOnboarding = false;
  late final Future<void> _initFuture;

  final _authStateController = StreamController<bool>.broadcast();

  @override
  String? get accessToken => _accessToken;

  @override
  String? get refreshToken => _refreshToken;

  @override
  bool get isAuthenticated =>
      _accessToken != null && _accessToken!.trim().isNotEmpty;

  @override
  bool get hasSeenOnboarding => _hasSeenOnboarding;

  @override
  Stream<bool> get authStateChanges => _authStateController.stream;

  Future<void> ensureInitialized() => _initFuture;

  Future<File> _getFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$_fileName');
  }

  Future<void> _loadFromDisk() async {
    try {
      final file = await _getFile();
      if (await file.exists()) {
        final content = await file.readAsString();
        if (content.trim().isNotEmpty) {
          final data = jsonDecode(content) as Map<String, dynamic>;
          _accessToken = data['accessToken'] as String?;
          _refreshToken = data['refreshToken'] as String?;
          _hasSeenOnboarding = data['hasSeenOnboarding'] as bool? ?? false;
          if (isAuthenticated) {
            _authStateController.add(true);
          }
        }
      }
    } catch (_) {}
  }

  Future<void> _writeToDisk() async {
    try {
      final file = await _getFile();
      final data = <String, dynamic>{
        'accessToken': _accessToken,
        'refreshToken': _refreshToken,
        'hasSeenOnboarding': _hasSeenOnboarding,
      };
      await file.writeAsString(jsonEncode(data), flush: true);
    } catch (_) {}
  }

  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    _accessToken = accessToken;
    _refreshToken = refreshToken;
    _hasSeenOnboarding = true;
    _authStateController.add(true);
    await _writeToDisk();
  }

  @override
  Future<void> clearTokens() async {
    _accessToken = null;
    _refreshToken = null;
    _authStateController.add(false);
    await _writeToDisk();
  }

  @override
  Future<void> setHasSeenOnboarding({bool seen = true}) async {
    _hasSeenOnboarding = seen;
    await _writeToDisk();
  }

  Future<void> dispose() async {
    await _authStateController.close();
  }
}
