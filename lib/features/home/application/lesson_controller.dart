import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/lesson_repository.dart';
import '../domain/models/lesson_model.dart';

final lessonBundleProvider = FutureProvider.autoDispose
    .family<CourseLessonBundle, String>((ref, courseId) {
      return ref.watch(lessonRepositoryProvider).fetchLessons(courseId);
    });

final lessonDetailProvider = FutureProvider.autoDispose
    .family<LessonDetailModel, LessonDetailRequest>((ref, request) {
      return ref
          .watch(lessonRepositoryProvider)
          .fetchLessonDetail(
            courseId: request.courseId,
            lessonId: request.lessonId,
          );
    });

class LessonDetailRequest {
  const LessonDetailRequest({required this.courseId, required this.lessonId});

  final String courseId;
  final String lessonId;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is LessonDetailRequest &&
            other.courseId == courseId &&
            other.lessonId == lessonId;
  }

  @override
  int get hashCode => Object.hash(courseId, lessonId);
}
