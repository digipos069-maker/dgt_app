import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/app_exception.dart';
import '../../auth/application/auth_controller.dart';
import '../data/tutorial_repository.dart';
import '../domain/models/lesson_model.dart';

const tutorialCacheDuration = Duration(minutes: 10);

class TutorialBundleNotifier extends AsyncNotifier<CourseLessonBundle> {
  TutorialBundleNotifier(this.arg);

  final TutorialRequest arg;
  bool _isFetchingMore = false;

  static const int initialLimit = 10;
  static const int scrollLimit = 5;

  @override
  Future<CourseLessonBundle> build() async {
    _isFetchingMore = false;
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

    return _fetchPage(page: 1, limit: initialLimit);
  }

  Future<CourseLessonBundle> _fetchPage({
    required int page,
    required int limit,
    int? offset,
  }) async {
    final authState = ref.watch(authControllerProvider);
    final user = switch (authState) {
      AsyncData(:final value) => value,
      _ => null,
    };
    final token = user?.token;
    if (token == null || token.isEmpty) {
      throw const AppException('Authentication is required');
    }

    return ref.read(tutorialRepositoryProvider).fetchTutorials(
      subjectId: arg.subjectId,
      gradeId: arg.gradeId,
      lessonId: arg.lessonId,
      token: token,
      page: page,
      limit: limit,
      offset: offset,
    );
  }

  Future<void> loadMore() async {
    final currentBundle = state.value;
    if (currentBundle == null ||
        !currentBundle.hasMore ||
        _isFetchingMore ||
        state.isLoading ||
        currentBundle.isFetchingMore) {
      return;
    }

    _isFetchingMore = true;
    state = AsyncData(currentBundle.copyWith(isFetchingMore: true));
    try {
      final currentCount = currentBundle.lessons.length;
      final nextPage = (currentCount ~/ scrollLimit) + 1;
      final newBundle = await _fetchPage(
        page: nextPage,
        limit: scrollLimit,
        offset: currentCount,
      );

      // Collect existing keys for deduplication
      final existingKeys = <String>{
        for (final lesson in currentBundle.lessons) _lessonKey(lesson),
      };

      // Filter only new/latest items that are not already present in the list
      final uniqueNewLessons = <LessonModel>[];
      for (final lesson in newBundle.lessons) {
        final key = _lessonKey(lesson);
        if (existingKeys.add(key)) {
          uniqueNewLessons.add(lesson);
        }
      }

      // If no new unique items were found, we've reached the end of the data
      final hasMore = newBundle.hasMore && uniqueNewLessons.isNotEmpty;
      final resolvedPage =
          (newBundle.page >= nextPage) ? newBundle.page : nextPage;

      state = AsyncData(
        currentBundle.copyWith(
          lessons: [...currentBundle.lessons, ...uniqueNewLessons],
          page: resolvedPage,
          hasMore: hasMore,
          isFetchingMore: false,
        ),
      );
    } catch (_) {
      state = AsyncData(currentBundle.copyWith(isFetchingMore: false));
    } finally {
      _isFetchingMore = false;
    }
  }

  String _lessonKey(LessonModel lesson) {
    if (lesson.id.isNotEmpty && lesson.id != '0') return lesson.id;
    if (lesson.slug.isNotEmpty) return lesson.slug;
    return lesson.title ?? lesson.titleKey;
  }
}

final tutorialBundleProvider = AsyncNotifierProvider.autoDispose
    .family<TutorialBundleNotifier, CourseLessonBundle, TutorialRequest>(
      (arg) => TutorialBundleNotifier(arg),
    );

final tutorialDetailProvider = FutureProvider.autoDispose
    .family<LessonDetailModel, TutorialDetailRequest>((ref, request) {
      final authState = ref.watch(authControllerProvider);
      final user = switch (authState) {
        AsyncData(:final value) => value,
        _ => null,
      };
      final token = user?.token;
      if (token == null || token.isEmpty) {
        throw const AppException('Authentication is required');
      }

      return ref
          .watch(tutorialRepositoryProvider)
          .fetchTutorialDetail(
            courseId: request.courseId,
            slug: request.slug,
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

class TutorialDetailRequest {
  const TutorialDetailRequest({required this.courseId, required this.slug});

  final String courseId;
  final String slug;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is TutorialDetailRequest &&
            other.courseId == courseId &&
            other.slug == slug;
  }

  @override
  int get hashCode => Object.hash(courseId, slug);
}
