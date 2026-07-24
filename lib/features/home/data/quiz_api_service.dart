import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/constants/api_constants.dart';
import '../../../core/utils/app_exception.dart';

class QuizApiService {
  QuizApiService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<Object?> submitQuiz({
    required int quizId,
    required String answer,
    required String token,
  }) async {
    final uri = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.quizSubmitPath}',
    );
    final response = await _client
        .post(
          uri,
          headers: {
            'Accept': '*/*',
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({'quizId': quizId, 'answer': answer}),
        )
        .timeout(const Duration(seconds: 15));
    final jsonBody = _decodeBody(response.body);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw AppException(
        _readMessage(jsonBody) ?? 'Failed to submit quiz answer',
        statusCode: response.statusCode,
      );
    }
    return jsonBody;
  }

  Object? _decodeBody(String body) {
    if (body.trim().isEmpty) return const <String, dynamic>{};
    try {
      return jsonDecode(body);
    } on FormatException {
      return <String, dynamic>{'message': body.trim()};
    }
  }

  String? _readMessage(Object? jsonBody) {
    if (jsonBody is! Map<String, dynamic>) return null;
    final message = jsonBody['message'] ?? jsonBody['error'];
    return message is String && message.trim().isNotEmpty
        ? message.trim()
        : null;
  }
}
