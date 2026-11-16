import 'dart:async';
import 'package:injectable/injectable.dart';

/// Contract for token and auth session persistence.
abstract interface class TokenStorage {
  String? get accessToken;
  String? get refreshToken;
  bool get isAuthenticated;

  Stream<bool> get authStateChanges;

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  });

  Future<void> clearTokens();
}

/// In-memory + session implementation of [TokenStorage].
@LazySingleton(as: TokenStorage)
class InMemoryTokenStorage implements TokenStorage {
  InMemoryTokenStorage();

  String? _accessToken;
  String? _refreshToken;

  final _authStateController = StreamController<bool>.broadcast();

  @override
  String? get accessToken => _accessToken;

  @override
  String? get refreshToken => _refreshToken;

  @override
  bool get isAuthenticated => _accessToken != null && _accessToken!.isNotEmpty;

  @override
  Stream<bool> get authStateChanges => _authStateController.stream;

  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    _accessToken = accessToken;
    _refreshToken = refreshToken;
    _authStateController.add(true);
  }

  @override
  Future<void> clearTokens() async {
    _accessToken = null;
    _refreshToken = null;
    _authStateController.add(false);
  }

  Future<void> dispose() async {
    await _authStateController.close();
  }
}
