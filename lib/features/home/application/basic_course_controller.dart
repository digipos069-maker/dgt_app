import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/application/auth_controller.dart';

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
    .family<BasicLessonBundle, BasicLessonsRequest>((ref, request) async {
      try {
        final authState = ref.watch(authControllerProvider);
        final user = switch (authState) {
          AsyncData(:final value) => value,
          _ => null,
        };
        final token = user?.token;
        if (token == null || token.isEmpty) throw Exception('Unauthorized');

        return await ref
            .watch(basicCourseRepositoryProvider)
            .fetchBasicLessons(
              token: token,
              courseId: request.courseId,
              languageCode: request.languageCode,
            );
      } catch (e, st) {
        print('Error in basicLessonsProvider: $e\n$st');
        rethrow;
      }
    });

final basicLessonDetailProvider = FutureProvider.autoDispose
    .family<LessonDetailModel, BasicLessonDetailRequest>((ref, request) async {
      try {
        final authState = ref.watch(authControllerProvider);
        final user = switch (authState) {
          AsyncData(:final value) => value,
          _ => null,
        };
        final token = user?.token;
        if (token == null || token.isEmpty) throw Exception('Unauthorized');

        return await ref
            .watch(basicCourseRepositoryProvider)
            .fetchBasicLessonDetail(
              token: token,
              courseId: request.courseId,
              lessonId: request.lessonId,
              languageCode: request.languageCode,
            );
      } catch (e, st) {
        print('Error in basicLessonDetailProvider: $e\n$st');
        rethrow;
      }
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
