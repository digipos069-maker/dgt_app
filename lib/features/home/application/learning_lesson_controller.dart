import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/learning_lesson_repository.dart';
import '../domain/models/learning_lesson_model.dart';

const learningLessonsCacheDuration = Duration(minutes: 10);

class LearningLessonsNotifier extends AsyncNotifier<LearningLessonBundle> {
  LearningLessonsNotifier(this.arg);

  final LearningLessonsRequest arg;
  bool _isFetchingMore = false;

  static const int initialLimit = 10;
  static const int scrollLimit = 5;

  @override
  Future<LearningLessonBundle> build() async {
    _isFetchingMore = false;
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

    return _fetchPage(page: 1, limit: initialLimit);
  }

  Future<LearningLessonBundle> _fetchPage({
    required int page,
    required int limit,
    int? offset,
  }) async {
    return ref.read(learningLessonRepositoryProvider).fetchLessons(
      gradeId: arg.gradeId,
      subjectId: arg.subjectId,
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

      final existingIds = <String>{
        for (final lesson in currentBundle.lessons) lesson.id,
      };

      final uniqueNewLessons = <LearningLessonModel>[];
      for (final lesson in newBundle.lessons) {
        if (existingIds.add(lesson.id)) {
          uniqueNewLessons.add(lesson);
        }
      }

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
}

final learningLessonsProvider = AsyncNotifierProvider.autoDispose
    .family<LearningLessonsNotifier, LearningLessonBundle, LearningLessonsRequest>(
      (arg) => LearningLessonsNotifier(arg),
    );

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
