enum AiTutorRole { user, model }

class AiTutorMessage {
  const AiTutorMessage({
    required this.id,
    required this.role,
    required this.text,
    this.errorKey,
    this.isStreaming = false,
    this.requiresLesson = false,
  });

  final String id;
  final AiTutorRole role;
  final String text;

  /// Localization key of the error shown instead of a reply (null on success).
  final String? errorKey;

  /// True while the tutor is still writing this reply.
  final bool isStreaming;

  /// Local tutor reply asking the student to choose a lesson first
  /// (never sent to the server, never part of the AI history).
  final bool requiresLesson;

  bool get isUser => role == AiTutorRole.user;
  bool get isError => errorKey != null;

  AiTutorMessage copyWith({String? text, String? errorKey, bool? isStreaming}) {
    return AiTutorMessage(
      id: id,
      role: role,
      text: text ?? this.text,
      errorKey: errorKey ?? this.errorKey,
      isStreaming: isStreaming ?? this.isStreaming,
      requiresLesson: requiresLesson,
    );
  }

  Map<String, String> toHistoryJson() => {
    'role': role == AiTutorRole.user ? 'user' : 'model',
    'text': text,
  };
}
