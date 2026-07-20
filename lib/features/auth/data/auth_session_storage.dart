import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../domain/models/user_model.dart';

final authSessionStorageProvider = Provider<AuthSessionStorage>((ref) {
  return SecureAuthSessionStorage(const FlutterSecureStorage());
});

abstract interface class AuthSessionStorage {
  Future<UserModel?> readSession();

  Future<void> saveSession(UserModel user);

  Future<void> clearSession();
}

class SecureAuthSessionStorage implements AuthSessionStorage {
  const SecureAuthSessionStorage(this._storage);

  static const _sessionKey = 'dgt.auth.session';

  final FlutterSecureStorage _storage;

  @override
  Future<UserModel?> readSession() async {
    final value = await _storage.read(key: _sessionKey);
    if (value == null || value.isEmpty) return null;

    try {
      final json = jsonDecode(value);
      if (json is! Map<String, dynamic>) return null;
      return UserModel.fromLoginResponse(json);
    } on FormatException {
      await clearSession();
      return null;
    }
  }

  @override
  Future<void> saveSession(UserModel user) {
    return _storage.write(
      key: _sessionKey,
      value: jsonEncode(user.toStoredSessionJson()),
    );
  }

  @override
  Future<void> clearSession() => _storage.delete(key: _sessionKey);
}
