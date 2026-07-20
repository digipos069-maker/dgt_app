import 'dart:convert';

import 'package:dgt_app/core/utils/jwt_utils.dart';
import 'package:dgt_app/features/auth/application/auth_controller.dart';
import 'package:dgt_app/features/auth/data/auth_repository.dart';
import 'package:dgt_app/features/auth/data/auth_session_storage.dart';
import 'package:dgt_app/features/auth/domain/models/user_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('restores a cached session when the JWT is still valid', () async {
    final token = _jwt(
      expiration: DateTime.now().add(const Duration(hours: 1)),
    );
    final cachedUser = _user(token);
    final storage = _MemoryAuthSessionStorage(cachedUser);
    final repository = _FakeAuthRepository(cachedUser);
    final container = ProviderContainer(
      overrides: [
        authSessionStorageProvider.overrideWithValue(storage),
        authRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);

    final restoredUser = await container.read(authControllerProvider.future);

    expect(restoredUser?.token, token);
    expect(storage.clearCount, 0);
  });

  test('clears an expired cached session', () async {
    final token = _jwt(
      expiration: DateTime.now().subtract(const Duration(minutes: 1)),
    );
    final storage = _MemoryAuthSessionStorage(_user(token));
    final container = ProviderContainer(
      overrides: [authSessionStorageProvider.overrideWithValue(storage)],
    );
    addTearDown(container.dispose);

    final restoredUser = await container.read(authControllerProvider.future);

    expect(restoredUser, isNull);
    expect(storage.clearCount, 1);
    expect(JwtUtils.isExpired(token), isTrue);
  });

  test('persists the session after login', () async {
    final token = _jwt(
      expiration: DateTime.now().add(const Duration(hours: 1)),
    );
    final loggedInUser = _user(token);
    final storage = _MemoryAuthSessionStorage(null);
    final repository = _FakeAuthRepository(loggedInUser);
    final container = ProviderContainer(
      overrides: [
        authSessionStorageProvider.overrideWithValue(storage),
        authRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);
    await container.read(authControllerProvider.future);

    final success = await container
        .read(authControllerProvider.notifier)
        .login(email: 'student@example.com', password: 'password');

    expect(success, isTrue);
    expect(storage.savedUser?.token, token);
  });

  test(
    'login succeeds when secure storage is temporarily unavailable',
    () async {
      final token = _jwt(
        expiration: DateTime.now().add(const Duration(hours: 1)),
      );
      final loggedInUser = _user(token);
      final storage = _MemoryAuthSessionStorage(null, failOnSave: true);
      final container = ProviderContainer(
        overrides: [
          authSessionStorageProvider.overrideWithValue(storage),
          authRepositoryProvider.overrideWithValue(
            _FakeAuthRepository(loggedInUser),
          ),
        ],
      );
      addTearDown(container.dispose);
      await container.read(authControllerProvider.future);

      final success = await container
          .read(authControllerProvider.notifier)
          .login(email: 'student@example.com', password: 'password');

      expect(success, isTrue);
      expect(container.read(authControllerProvider).value?.token, token);
    },
  );
}

class _MemoryAuthSessionStorage implements AuthSessionStorage {
  _MemoryAuthSessionStorage(this.savedUser, {this.failOnSave = false});

  UserModel? savedUser;
  final bool failOnSave;
  int clearCount = 0;

  @override
  Future<void> clearSession() async {
    clearCount++;
    savedUser = null;
  }

  @override
  Future<UserModel?> readSession() async => savedUser;

  @override
  Future<void> saveSession(UserModel user) async {
    if (failOnSave) throw StateError('Secure storage unavailable');
    savedUser = user;
  }
}

class _FakeAuthRepository implements AuthRepository {
  const _FakeAuthRepository(this.user);

  final UserModel user;

  @override
  Future<UserModel> currentUser({required String token}) async => user;

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async => user;

  @override
  Future<UserModel> register({
    required String fullName,
    required String email,
    required String password,
    required int gradeId,
  }) async => user;
}

UserModel _user(String token) {
  return UserModel(
    id: '12',
    email: 'student@example.com',
    username: 'Student',
    token: token,
    roles: const ['student'],
  );
}

String _jwt({required DateTime expiration}) {
  String encode(Map<String, Object> value) {
    return base64Url.encode(utf8.encode(jsonEncode(value))).replaceAll('=', '');
  }

  final expirationSeconds = expiration.millisecondsSinceEpoch ~/ 1000;
  return '${encode({'alg': 'none', 'typ': 'JWT'})}.${encode({'exp': expirationSeconds})}.signature';
}
