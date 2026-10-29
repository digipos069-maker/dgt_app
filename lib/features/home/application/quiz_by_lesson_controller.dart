import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/application/auth_controller.dart';
import '../data/quiz_repository.dart';
import '../domain/models/quiz_by_lesson_model.dart';

class QuizByLessonArgs {
  const QuizByLessonArgs({
    required this.lessonId,
    this.size = 15,
  });

  final int lessonId;
  final int size;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuizByLessonArgs &&
          runtimeType == other.runtimeType &&
          lessonId == other.lessonId &&
          size == other.size;

  @override
  int get hashCode => Object.hash(lessonId, size);
}

final quizByLessonProvider = FutureProvider.autoDispose
    .family<QuizByLessonResponse, QuizByLessonArgs>((ref, args) async {
  final authState = ref.watch(authControllerProvider);
  final token = switch (authState) {
    AsyncData(:final value) => value?.token,
    _ => null,
  };

  return ref.watch(quizRepositoryProvider).getQuizByLesson(
    lessonId: args.lessonId,
    size: args.size,
    token: token,
  );
});

final quizByLessonIdProvider = Provider.autoDispose
    .family<AsyncValue<QuizByLessonResponse>, int>((ref, lessonId) {
  return ref.watch(quizByLessonProvider(QuizByLessonArgs(lessonId: lessonId)));
});
