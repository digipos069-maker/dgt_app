import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/constants/api_constants.dart';
import '../../../core/utils/app_exception.dart';

class LearningLessonApiService {
  LearningLessonApiService({http.Client? client})
    : _client = client ?? http.Client();

  final http.Client _client;

  Future<Object?> fetchLessons({
    required int gradeId,
    required int subjectId,
    int page = 1,
    int limit = 10,
    int? offset,
  }) async {
    final queryParams = {
      'subjectId': subjectId.toString(),
      'gradeId': gradeId.toString(),
      'page': page.toString(),
      'limit': limit.toString(),
      if (offset != null) 'offset': offset.toString(),
    };
    final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.lessonsPath}')
        .replace(queryParameters: queryParams);
    final response = await _client
        .get(uri, headers: const {'Accept': '*/*'})
        .timeout(const Duration(seconds: 15));
    final jsonBody = _decodeBody(response.body);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw AppException(_readMessage(jsonBody) ?? 'Failed to load lessons');
    }

    return jsonBody;
  }

  Object? _decodeBody(String body) {
    if (body.trim().isEmpty) return const <Object?>[];
    return jsonDecode(body);
  }

  List<Object?> _readList(Object? jsonBody) {
    if (jsonBody is List) return jsonBody;

    if (jsonBody is Map<String, dynamic>) {
      for (final key in const ['data', 'lessons', 'items', 'results', 'rows']) {
        final value = jsonBody[key];
        if (value is List) return value;
        if (value is Map<String, dynamic>) {
          final nested = _tryReadList(value);
          if (nested != null) return nested;
        }
      }
    }

    throw const AppException('Invalid lessons response');
  }

  List<Object?>? _tryReadList(Map<String, dynamic> json) {
    for (final key in const ['data', 'lessons', 'items', 'results', 'rows']) {
      final value = json[key];
      if (value is List) return value;
    }
    return null;
  }

  String? _readMessage(Object? jsonBody) {
    if (jsonBody is! Map<String, dynamic>) return null;
    final message = jsonBody['message'] ?? jsonBody['error'];
    return message is String && message.trim().isNotEmpty ? message : null;
  }
}
