import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/basic_course_repository.dart';
import '../domain/models/basic_course_model.dart';
import '../domain/models/basic_lesson_model.dart';
import '../domain/models/lesson_model.dart';

final basicCoursesProvider = FutureProvider.autoDispose
    .family<List<BasicCourseModel>, String>((ref, languageCode) {
      return ref
          .watch(basicCourseRepositoryProvider)
          .fetchBasicCourses(languageCode: languageCode);
    });

final basicLessonsProvider = FutureProvider.autoDispose
    .family<BasicLessonBundle, BasicLessonsRequest>((ref, request) {
      return ref
          .watch(basicCourseRepositoryProvider)
          .fetchBasicLessons(
            courseId: request.courseId,
            languageCode: request.languageCode,
          );
    });

final basicLessonDetailProvider = FutureProvider.autoDispose
    .family<LessonDetailModel, BasicLessonDetailRequest>((ref, request) {
      return ref
          .watch(basicCourseRepositoryProvider)
          .fetchBasicLessonDetail(
            courseId: request.courseId,
            lessonId: request.lessonId,
            languageCode: request.languageCode,
          );
    });

class BasicLessonsRequest {
  const BasicLessonsRequest({
    required this.courseId,
    required this.languageCode,
  });

  final String courseId;
  final String languageCode;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is BasicLessonsRequest &&
            other.courseId == courseId &&
            other.languageCode == languageCode;
  }

  @override
  int get hashCode => Object.hash(courseId, languageCode);
}

class BasicLessonDetailRequest {
  const BasicLessonDetailRequest({
    required this.courseId,
    required this.lessonId,
    required this.languageCode,
  });

  final String courseId;
  final String lessonId;
  final String languageCode;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is BasicLessonDetailRequest &&
            other.courseId == courseId &&
            other.lessonId == lessonId &&
            other.languageCode == languageCode;
  }

  @override
  int get hashCode => Object.hash(courseId, lessonId, languageCode);
}
