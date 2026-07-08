import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/models/user_model.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return MockAuthRepository();
});

abstract interface class AuthRepository {
  Future<UserModel> login({required String email, required String password});

  Future<UserModel> register({
    required String username,
    required String email,
    required String password,
    required String grade,
  });
}

class MockAuthRepository implements AuthRepository {
  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 700));
    return UserModel(
      id: 'mock-user',
      email: email,
      username: email.split('@').first,
    );
  }

  @override
  Future<UserModel> register({
    required String username,
    required String email,
    required String password,
    required String grade,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 900));
    return UserModel(
      id: 'mock-user',
      email: email,
      username: username,
      grade: grade,
    );
  }
}
