import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/learning_lesson_repository.dart';
import '../domain/models/learning_lesson_model.dart';

const learningLessonsCacheDuration = Duration(minutes: 10);

final learningLessonsProvider = FutureProvider.autoDispose
    .family<List<LearningLessonModel>, LearningLessonsRequest>((ref, request) {
      final cacheLink = ref.keepAlive();
      Timer? cacheTimer;

      ref.onCancel(() {
        cacheTimer = Timer(learningLessonsCacheDuration, cacheLink.close);
      });
      ref.onResume(() {
        cacheTimer?.cancel();
        cacheTimer = null;
      });
      ref.onDispose(() => cacheTimer?.cancel());

      return ref
          .watch(learningLessonRepositoryProvider)
          .fetchLessons(gradeId: request.gradeId, subjectId: request.subjectId);
    });

class LearningLessonsRequest {
  const LearningLessonsRequest({
    required this.gradeId,
    required this.subjectId,
  });

  final int gradeId;
  final int subjectId;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is LearningLessonsRequest &&
            other.gradeId == gradeId &&
            other.subjectId == subjectId;
  }

  @override
  int get hashCode => Object.hash(gradeId, subjectId);
}
