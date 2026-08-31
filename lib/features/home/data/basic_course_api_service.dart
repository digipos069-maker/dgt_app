import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../../core/constants/api_constants.dart';
import '../domain/models/basic_lesson_model.dart';
import '../domain/models/basic_course_model.dart';

final basicCourseApiServiceProvider = Provider<BasicCourseApiService>((ref) {
  return BasicCourseApiService();
});

class BasicCourseApiService {
  BasicCourseApiService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<Map<String, dynamic>> fetchBasicContentRaw({
    required String token,
    required String subjectId,
    int page = 1,
    int limit = 10,
    int? offset,
  }) async {
    final queryParams = {
      'subjectId': subjectId,
      'page': page.toString(),
      'limit': limit.toString(),
      if (offset != null) 'offset': offset.toString(),
    };
    final uri = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.basicContentPath}',
    ).replace(queryParameters: queryParams);
    final response = await _client.get(
      uri,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    ).timeout(const Duration(seconds: 15));

    final jsonBody = _decodeBody(response.body);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        _readMessage(jsonBody) ??
            'Failed to load basic content (Status ${response.statusCode})',
      );
    }

    return jsonBody;
  }

  Future<Map<String, dynamic>> fetchBasicContentDetail({
    required String token,
    required String slug,
  }) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.basicContentPath}/slug/$slug');
    final response = await _client.get(
      uri,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    ).timeout(const Duration(seconds: 15));

    final jsonBody = _decodeBody(response.body);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(_readMessage(jsonBody) ?? 'Failed to load basic content detail (Status ${response.statusCode})');
    }

    return jsonBody;
  }

  Map<String, dynamic> _decodeBody(String body) {
    if (body.isEmpty) return {};
    try {
      return jsonDecode(body) as Map<String, dynamic>;
    } catch (_) {
      return {};
    }
  }

  String? _readMessage(Map<String, dynamic> body) {
    if (body['message'] is String) return body['message'] as String;
    if (body['error'] is String) return body['error'] as String;
    return null;
  }
}
