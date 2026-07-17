import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/constants/api_constants.dart';
import '../../../core/utils/app_exception.dart';

class TutorialApiService {
  TutorialApiService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<List<Object?>> fetchTutorials({
    required int subjectId,
    required int gradeId,
    required int lessonId,
    required String token,
  }) async {
    final uri =
        Uri.parse(
          '${ApiConstants.baseUrl}${ApiConstants.tutorialsPath}',
        ).replace(
          queryParameters: {
            'subjectId': subjectId.toString(),
            'gradeId': gradeId.toString(),
            'lessonId': lessonId.toString(),
          },
        );
    final response = await _client
        .get(uri, headers: {'Accept': '*/*', 'Authorization': 'Bearer $token'})
        .timeout(const Duration(seconds: 15));
    final jsonBody = _decodeBody(response.body);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw AppException(_readMessage(jsonBody) ?? 'Failed to load tutorials');
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
      for (final key in const [
        'data',
        'tutorials',
        'items',
        'results',
        'rows',
      ]) {
        final value = jsonBody[key];
        if (value is List) return value;
        if (value is Map<String, dynamic>) {
          for (final nestedKey in const [
            'data',
            'tutorials',
            'items',
            'results',
            'rows',
          ]) {
            final nested = value[nestedKey];
            if (nested is List) return nested;
          }
        }
      }
    }
    throw const AppException('Invalid tutorials response');
  }

  String? _readMessage(Object? jsonBody) {
    if (jsonBody is! Map<String, dynamic>) return null;
    final message = jsonBody['message'] ?? jsonBody['error'];
    return message is String && message.trim().isNotEmpty ? message : null;
  }
}
