import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/auth_repository.dart';
import '../domain/models/user_model.dart';

final authControllerProvider =
    AsyncNotifierProvider<AuthController, UserModel?>(AuthController.new);

class AuthController extends AsyncNotifier<UserModel?> {
  @override
  UserModel? build() {
    // Temporary development session. Replace this with persisted/API auth later.
    return const UserModel(
      id: 'mock-user',
      email: 'student@educambodia.com',
      username: 'Student',
      grade: 'Grade 11',
    );
  }

  Future<bool> login({required String email, required String password}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() {
      return ref
          .read(authRepositoryProvider)
          .login(email: email.trim(), password: password);
    });
    return !state.hasError;
  }

  Future<bool> register({
    required String username,
    required String email,
    required String password,
    required String grade,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() {
      return ref
          .read(authRepositoryProvider)
          .register(
            username: username.trim(),
            email: email.trim(),
            password: password,
            grade: grade,
          );
    });
    return !state.hasError;
  }

  void logout() {
    state = const AsyncData(null);
  }
}
