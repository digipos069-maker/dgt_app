import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/app_exception.dart';
import '../../auth/application/auth_controller.dart';
import '../data/tutorial_repository.dart';
import '../domain/models/lesson_model.dart';

const tutorialCacheDuration = Duration(minutes: 10);

final tutorialBundleProvider = FutureProvider.autoDispose
    .family<CourseLessonBundle, TutorialRequest>((ref, request) {
      final authState = ref.watch(authControllerProvider);
      final user = switch (authState) {
        AsyncData(:final value) => value,
        _ => null,
      };
      final token = user?.token;
      if (token == null || token.isEmpty) {
        throw const AppException('Authentication is required');
      }

      final cacheLink = ref.keepAlive();
      Timer? cacheTimer;
      ref.onCancel(() {
        cacheTimer = Timer(tutorialCacheDuration, cacheLink.close);
      });
      ref.onResume(() {
        cacheTimer?.cancel();
        cacheTimer = null;
      });
      ref.onDispose(() => cacheTimer?.cancel());

      return ref
          .watch(tutorialRepositoryProvider)
          .fetchTutorials(
            subjectId: request.subjectId,
            gradeId: request.gradeId,
            lessonId: request.lessonId,
            token: token,
          );
    });

class TutorialRequest {
  const TutorialRequest({
    required this.subjectId,
    required this.gradeId,
    required this.lessonId,
  });

  final int subjectId;
  final int gradeId;
  final int lessonId;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is TutorialRequest &&
            other.subjectId == subjectId &&
            other.gradeId == gradeId &&
            other.lessonId == lessonId;
  }

  @override
  int get hashCode => Object.hash(subjectId, gradeId, lessonId);
}
