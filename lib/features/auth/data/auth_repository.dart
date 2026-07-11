import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/models/user_model.dart';
import 'auth_api_service.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return ApiAuthRepository(AuthApiService());
});

abstract interface class AuthRepository {
  Future<UserModel> login({required String email, required String password});

  Future<UserModel> register({
    required String fullName,
    required String email,
    required String password,
    required int gradeId,
  });
}

class ApiAuthRepository implements AuthRepository {
  const ApiAuthRepository(this._apiService);

  final AuthApiService _apiService;

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final response = await _apiService.login(email: email, password: password);
    return UserModel.fromLoginResponse(response);
  }

  @override
  Future<UserModel> register({
    required String fullName,
    required String email,
    required String password,
    required int gradeId,
  }) async {
    final response = await _apiService.register(
      fullName: fullName,
      email: email,
      password: password,
      gradeId: gradeId,
    );
    return UserModel.fromLoginResponse(response);
  }
}
