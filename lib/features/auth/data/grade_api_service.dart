import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/constants/api_constants.dart';
import '../../../core/utils/app_exception.dart';

class GradeApiService {
  GradeApiService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<List<Object?>> fetchGrades() async {
    final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.gradesPath}');
    final response = await _client
        .get(uri, headers: const {'Accept': 'application/json'})
        .timeout(const Duration(seconds: 15));
    final jsonBody = _decodeBody(response.body);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw AppException(_readMessage(jsonBody) ?? 'Failed to load grades');
    }

    return _readList(jsonBody);
  }

  Object? _decodeBody(String body) {
    if (body.trim().isEmpty) return const <Object?>[];
    return jsonDecode(body);
  }

  List<Object?> _readList(Object? jsonBody) {
    if (jsonBody is List) return jsonBody;

    if (jsonBody is Map<String, dynamic>) {
      final data = jsonBody['data'] ?? jsonBody['grades'] ?? jsonBody['items'];
      if (data is List) return data;
    }

    throw const AppException('Invalid grades response');
  }

  String? _readMessage(Object? jsonBody) {
    if (jsonBody is! Map<String, dynamic>) return null;
    final message = jsonBody['message'] ?? jsonBody['error'];
    return message is String && message.trim().isNotEmpty ? message : null;
  }
}
