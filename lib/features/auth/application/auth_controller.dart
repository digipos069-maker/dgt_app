import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/auth_repository.dart';
import '../domain/models/user_model.dart';

final authControllerProvider =
    AsyncNotifierProvider<AuthController, UserModel?>(AuthController.new);

class AuthController extends AsyncNotifier<UserModel?> {
  @override
  UserModel? build() => null;

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
    required String fullName,
    required String email,
    required String password,
    required int gradeId,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() {
      return ref
          .read(authRepositoryProvider)
          .register(
            fullName: fullName.trim(),
            email: email.trim(),
            password: password,
            gradeId: gradeId,
          );
    });
    return !state.hasError;
  }

  void logout() {
    state = const AsyncData(null);
  }
}
