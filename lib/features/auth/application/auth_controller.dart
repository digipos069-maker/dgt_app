import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/app_exception.dart';
import '../../../core/utils/jwt_utils.dart';
import '../data/auth_repository.dart';
import '../data/auth_session_storage.dart';
import '../domain/models/user_model.dart';

final authControllerProvider =
    AsyncNotifierProvider<AuthController, UserModel?>(AuthController.new);

class AuthController extends AsyncNotifier<UserModel?> {
  @override
  Future<UserModel?> build() async {
    try {
      final storage = ref.read(authSessionStorageProvider);
      final cachedUser = await storage.readSession();
      final token = cachedUser?.token;
      if (cachedUser == null || token == null || JwtUtils.isExpired(token)) {
        await storage.clearSession();
        return null;
      }

      unawaited(
        Future<void>.delayed(
          Duration.zero,
          () => _refreshRestoredSession(cachedUser),
        ),
      );
      return cachedUser;
    } on Object {
      return null;
    }
  }

  Future<bool> login({required String email, required String password}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final user = await ref
          .read(authRepositoryProvider)
          .login(email: email.trim(), password: password);
      await _persistSession(user);
      return user;
    });
    return !state.hasError;
  }

  Future<bool> register({
    required String fullName,
    required String email,
    required String password,
    required int gradeId,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final user = await ref
          .read(authRepositoryProvider)
          .register(
            fullName: fullName.trim(),
            email: email.trim(),
            password: password,
            gradeId: gradeId,
          );
      await _persistSession(user);
      return user;
    });
    return !state.hasError;
  }

  void logout() {
    state = const AsyncData(null);
    unawaited(_clearStoredSession());
  }

  Future<void> _refreshRestoredSession(UserModel cachedUser) async {
    final token = cachedUser.token;
    if (token == null) return;

    try {
      final refreshedUser = await ref
          .read(authRepositoryProvider)
          .currentUser(token: token);
      final currentUser = switch (state) {
        AsyncData(:final value) => value,
        _ => null,
      };
      if (currentUser?.token != token) return;

      await _persistSession(refreshedUser);
      state = AsyncData(refreshedUser);
    } on AppException catch (error) {
      if (error.statusCode != 401 && error.statusCode != 403) return;

      await _clearStoredSession();
      final currentToken = switch (state) {
        AsyncData(:final value) => value?.token,
        _ => null,
      };
      if (currentToken == token) state = const AsyncData(null);
    } on Object {
      // A transient network failure must not discard an unexpired session.
    }
  }

  Future<void> _persistSession(UserModel user) async {
    try {
      await ref.read(authSessionStorageProvider).saveSession(user);
    } on Object catch (error, stackTrace) {
      developer.log(
        'Unable to persist the authenticated session',
        name: 'dgt.auth',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> _clearStoredSession() async {
    try {
      await ref.read(authSessionStorageProvider).clearSession();
    } on Object catch (error, stackTrace) {
      developer.log(
        'Unable to clear the stored session',
        name: 'dgt.auth',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }
}
