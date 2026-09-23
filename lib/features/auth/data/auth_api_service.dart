import 'dart:async';
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
    final response = await _sendLoginRequest(uri, email, password);
    final jsonBody = _decodeLoginResponse(response);

    if (response.statusCode < 200 ||
        response.statusCode >= 300 ||
        jsonBody['success'] == false) {
      throw AppException(
        _readMessage(jsonBody) ?? _loginFailureMessage(response.statusCode),
        statusCode: response.statusCode,
      );
    }

    return jsonBody;
  }

  Future<http.Response> _sendLoginRequest(
    Uri uri,
    String email,
    String password,
  ) async {
    try {
      return await _client
          .post(
            uri,
            headers: const {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              if (email.contains('@')) 'email': email else 'phone': email,
              'password': password,
            }),
          )
          .timeout(const Duration(seconds: 15));
    } on TimeoutException {
      throw const AppException(
        'The login server took too long to respond. Please try again.',
      );
    } on http.ClientException {
      throw const AppException(
        'Cannot connect to the login server. Check your connection and try again.',
      );
    }
  }

  Map<String, dynamic> _decodeLoginResponse(http.Response response) {
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) return decoded;
    } on FormatException {
      // Proxies and security gateways can return HTML instead of API JSON.
    }

    throw AppException(
      response.statusCode < 200 || response.statusCode >= 300
          ? _loginFailureMessage(response.statusCode)
          : 'The login server returned an invalid response. Please try again later.',
      statusCode: response.statusCode,
    );
  }

  String _loginFailureMessage(int statusCode) {
    return switch (statusCode) {
      401 => 'The email, phone number, or password is incorrect.',
      403 => 'Access to the login server was denied. Please contact support.',
      429 => 'Too many login attempts. Please wait before trying again.',
      >= 500 => 'The login server is unavailable. Please try again later.',
      _ => 'Login failed. Please try again or contact support.',
    };
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
            if (email.contains('@')) 'email': email else 'phone': email,
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
      throw AppException(
        _readMessage(jsonBody) ?? 'Failed to load profile',
        statusCode: response.statusCode,
      );
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
