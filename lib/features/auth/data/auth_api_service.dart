import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/constants/api_constants.dart';
import '../../../core/utils/app_exception.dart';

class AuthApiService {
  AuthApiService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.loginPath}');
    final response = await _client
        .post(
          uri,
          headers: const {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({'email': email, 'password': password}),
        )
        .timeout(const Duration(seconds: 15));
    final jsonBody = _decodeBody(response.body);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw AppException(_readMessage(jsonBody) ?? 'Login failed');
    }
    if (jsonBody['success'] == false) {
      throw AppException(_readMessage(jsonBody) ?? 'Login failed');
    }

    return jsonBody;
  }

  Future<Map<String, dynamic>> register({
    required String fullName,
    required String email,
    required String password,
    required int gradeId,
  }) async {
    final uri = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.registerPath}',
    );
    final response = await _client
        .post(
          uri,
          headers: const {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'email': email,
            'fullName': fullName,
            'gradeId': gradeId,
            'password': password,
          }),
        )
        .timeout(const Duration(seconds: 15));
    final jsonBody = _decodeBody(response.body);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw AppException(_readMessage(jsonBody) ?? 'Register failed');
    }
    if (jsonBody['success'] == false) {
      throw AppException(_readMessage(jsonBody) ?? 'Register failed');
    }

    return jsonBody;
  }

  Future<Map<String, dynamic>> currentUser({required String token}) async {
    final uri = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.currentUserPath}',
    );
    final response = await _client
        .get(
          uri,
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        )
        .timeout(const Duration(seconds: 15));
    final jsonBody = _decodeBody(response.body);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw AppException(_readMessage(jsonBody) ?? 'Failed to load profile');
    }
    if (jsonBody['success'] == false) {
      throw AppException(_readMessage(jsonBody) ?? 'Failed to load profile');
    }

    return jsonBody;
  }

  Map<String, dynamic> _decodeBody(String body) {
    if (body.trim().isEmpty) return <String, dynamic>{};

    final decoded = jsonDecode(body);
    if (decoded is Map<String, dynamic>) return decoded;

    throw const AppException('Invalid server response');
  }

  String? _readMessage(Map<String, dynamic> json) {
    final message = json['message'] ?? json['error'];
    return message is String && message.trim().isNotEmpty ? message : null;
  }
}
