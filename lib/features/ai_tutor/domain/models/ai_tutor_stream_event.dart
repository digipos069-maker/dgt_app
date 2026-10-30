import 'dart:convert';

/// One Server-Sent Event from `POST /api/ai-tutor/chat/stream`.
sealed class AiTutorStreamEvent {
  const AiTutorStreamEvent();

  /// Parses a single SSE line such as `data: {"type":"delta","text":"Hi"}`.
  /// Returns null for blank lines, comments and unknown events.
  static AiTutorStreamEvent? tryParseSseLine(String line) {
    final trimmed = line.trim();
    if (!trimmed.startsWith('data:')) return null;
    final payload = trimmed.substring(5).trim();
    if (payload.isEmpty) return null;

    final Object? json;
    try {
      json = jsonDecode(payload);
    } on FormatException {
      return null;
    }
    if (json is! Map<String, dynamic>) return null;

    return switch (json['type']) {
      'delta' when json['text'] is String => AiTutorDelta(json['text'] as String),
      'done' => AiTutorDone(
        remaining: json['remaining'] is num ? (json['remaining'] as num).toInt() : null,
      ),
      'error' => AiTutorStreamFailure(
        json['message'] is String ? json['message'] as String : 'AI tutor error',
      ),
      _ => null,
    };
  }
}

class AiTutorDelta extends AiTutorStreamEvent {
  const AiTutorDelta(this.text);
  final String text;
}

class AiTutorDone extends AiTutorStreamEvent {
  const AiTutorDone({this.remaining});
  final int? remaining;
}

class AiTutorStreamFailure extends AiTutorStreamEvent {
  const AiTutorStreamFailure(this.message);
  final String message;
}
