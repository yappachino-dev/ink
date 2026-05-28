import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ink/core/infrastructure/storage/secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'session_repository.g.dart';

class SessionRepository {
  const SessionRepository({required FlutterSecureStorage storage})
    : _storage = storage;

  final FlutterSecureStorage _storage;

  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';

  Future<void> saveAccessToken(String accessToken) =>
      _storage.write(key: _accessTokenKey, value: accessToken);

  Future<void> saveRefreshToken(String refreshToken) =>
      _storage.write(key: _refreshTokenKey, value: refreshToken);

  Future<String?> readAccessToken() => _storage.read(key: _accessTokenKey);

  Future<String?> readRefreshToken() => _storage.read(key: _refreshTokenKey);

  Future<void> clearAccessToken() => _storage.delete(key: _accessTokenKey);

  Future<void> clearRefreshToken() => _storage.delete(key: _refreshTokenKey);
}

@Riverpod(keepAlive: true)
SessionRepository sessionRepository(Ref ref) =>
    SessionRepository(storage: ref.watch(secureStorageProvider));
