import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/constants/api_constants.dart';
import '../../../core/utils/app_exception.dart';
import '../domain/models/ai_tutor_stream_event.dart';

class AiTutorApiService {
  AiTutorApiService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  /// Max wait for the server to start answering.
  static const _connectTimeout = Duration(seconds: 60);

  /// Max silence between two streamed chunks before we give up.
  static const _idleTimeout = Duration(seconds: 45);

  /// Streams the tutor's answer chunk by chunk (ChatGPT-style).
  ///
  /// Cancelling the subscription aborts the HTTP request, which also stops
  /// generation on the server.
  Stream<AiTutorStreamEvent> streamMessage({
    required String token,
    required String message,
    required List<Map<String, String>> history,
    int? tutorialId,
  }) async* {
    final abortTrigger = Completer<void>();
    final request = http.AbortableRequest(
      'POST',
      Uri.parse('${ApiConstants.baseUrl}${ApiConstants.aiTutorChatStreamPath}'),
      abortTrigger: abortTrigger.future,
    )
      ..headers.addAll({
        'Accept': 'text/event-stream',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      })
      ..body = jsonEncode({
        if (tutorialId != null) 'tutorialId': tutorialId,
        'message': message,
        'history': history,
      });

    try {
      final http.StreamedResponse response;
      try {
        response = await _client.send(request).timeout(_connectTimeout);
      } on TimeoutException {
        throw const AppException('AI tutor timed out', statusCode: 408);
      }

      if (response.statusCode < 200 || response.statusCode >= 300) {
        final body = await response.stream.bytesToString();
        throw AppException(
          _readMessage(_tryDecode(body)) ?? 'AI tutor request failed',
          statusCode: response.statusCode,
        );
      }

      final lines = response.stream
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .timeout(
            _idleTimeout,
            onTimeout: (sink) {
              sink.addError(
                const AppException('AI tutor stopped responding', statusCode: 408),
              );
              sink.close();
            },
          );

      await for (final line in lines) {
        final event = AiTutorStreamEvent.tryParseSseLine(line);
        if (event != null) yield event;
      }
    } finally {
      // Runs on completion, error, or when the listener cancels ("stop").
      if (!abortTrigger.isCompleted) abortTrigger.complete();
    }
  }

  Future<Object?> fetchUsage({required String token}) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.aiTutorUsagePath}');
    final response = await _client
        .get(uri, headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'})
        .timeout(const Duration(seconds: 15));
    final body = _tryDecode(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw AppException(
        _readMessage(body) ?? 'Failed to load AI tutor usage',
        statusCode: response.statusCode,
      );
    }
    return body;
  }

  Future<Object?> fetchLessons({
    required String token,
    String query = '',
    bool allGrades = false,
  }) async {
    final uri = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.aiTutorLessonsPath}',
    ).replace(
      queryParameters: {
        if (query.trim().isNotEmpty) 'query': query.trim(),
        if (allGrades) 'allGrades': 'true',
        'limit': '50',
      },
    );
    final response = await _client
        .get(uri, headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'})
        .timeout(const Duration(seconds: 15));
    final body = _tryDecode(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw AppException(
        _readMessage(body) ?? 'Failed to load lessons',
        statusCode: response.statusCode,
      );
    }
    return body;
  }

  Object? _tryDecode(String body) {
    if (body.trim().isEmpty) return null;
    try {
      return jsonDecode(body);
    } on FormatException {
      return null;
    }
  }

  String? _readMessage(Object? body) {
    if (body is! Map<String, dynamic>) return null;
    final message = body['message'] ?? body['error'];
    if (message is List && message.isNotEmpty) return message.first.toString();
    return message is String && message.trim().isNotEmpty ? message : null;
  }
}
