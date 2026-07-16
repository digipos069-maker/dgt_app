import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/auth_repository.dart';
import '../domain/models/user_model.dart';
import 'auth_controller.dart';

final profileProvider = FutureProvider<UserModel?>((ref) async {
  final authState = ref.watch(authControllerProvider);
  final user = switch (authState) {
    AsyncData(:final value) => value,
    _ => null,
  };
  final token = user?.token;

  if (user == null || token == null || token.isEmpty) {
    return user;
  }

  return ref.watch(authRepositoryProvider).currentUser(token: token);
});
