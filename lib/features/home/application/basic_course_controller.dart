import 'dart:async';

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

class BasicLessonsNotifier extends AsyncNotifier<BasicLessonBundle> {
  BasicLessonsNotifier(this.arg);

  final BasicLessonsRequest arg;
  bool _isFetchingMore = false;

  static const int initialLimit = 10;
  static const int scrollLimit = 5;

  @override
  Future<BasicLessonBundle> build() async {
    _isFetchingMore = false;
    final cacheLink = ref.keepAlive();
    Timer? cacheTimer;

    ref.onCancel(() {
      cacheTimer = Timer(const Duration(minutes: 10), cacheLink.close);
    });
    ref.onResume(() {
      cacheTimer?.cancel();
      cacheTimer = null;
    });
    ref.onDispose(() => cacheTimer?.cancel());

    return _fetchPage(page: 1, limit: initialLimit);
  }

  Future<BasicLessonBundle> _fetchPage({
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
    if (token == null || token.isEmpty) throw Exception('Unauthorized');

    return ref.read(basicCourseRepositoryProvider).fetchBasicLessons(
      token: token,
      courseId: arg.courseId,
      languageCode: arg.languageCode,
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

      final uniqueNewLessons = <BasicLessonModel>[];
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

final basicLessonsProvider = AsyncNotifierProvider.autoDispose
    .family<BasicLessonsNotifier, BasicLessonBundle, BasicLessonsRequest>(
      (arg) => BasicLessonsNotifier(arg),
    );

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
