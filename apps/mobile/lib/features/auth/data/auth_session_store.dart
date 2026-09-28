import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract interface class AuthSessionStore {
  Future<String?> readToken();
  Future<void> writeToken(String token);
  Future<void> clearToken();
}

class SecureAuthSessionStore implements AuthSessionStore {
  static const _tokenKey = 'ride_together_access_token';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  @override
  Future<String?> readToken() => _storage.read(key: _tokenKey);

  @override
  Future<void> writeToken(String token) =>
      _storage.write(key: _tokenKey, value: token);

  @override
  Future<void> clearToken() => _storage.delete(key: _tokenKey);
}
