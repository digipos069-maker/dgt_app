import 'ai_tutor_lesson_ref.dart';
import 'ai_tutor_message.dart';

class AiTutorChatState {
  const AiTutorChatState({
    this.messages = const [],
    this.isSending = false,
    this.attachedLesson,
  });

  final List<AiTutorMessage> messages;
  final bool isSending;

  /// Lesson the answers are grounded in; null = general study help.
  final AiTutorLessonRef? attachedLesson;

  bool get isEmpty => messages.isEmpty;

  AiTutorChatState copyWith({
    List<AiTutorMessage>? messages,
    bool? isSending,
    AiTutorLessonRef? attachedLesson,
    bool clearAttachedLesson = false,
  }) {
    return AiTutorChatState(
      messages: messages ?? this.messages,
      isSending: isSending ?? this.isSending,
      attachedLesson: clearAttachedLesson ? null : (attachedLesson ?? this.attachedLesson),
    );
  }
}

/// Identifies one tutor conversation: opened from a lesson page ([tutorialId]
/// set) or from the AI Tutor tab (null). The attached lesson can change later.
class AiTutorSession {
  const AiTutorSession({this.tutorialId, this.lessonTitle});

  final int? tutorialId;
  final String? lessonTitle;

  /// The lesson the chat starts with, if opened from a lesson page.
  AiTutorLessonRef? get initialLesson => tutorialId == null
      ? null
      : AiTutorLessonRef(id: tutorialId!, title: lessonTitle ?? '');

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AiTutorSession && other.tutorialId == tutorialId;

  @override
  int get hashCode => tutorialId.hashCode;
}
