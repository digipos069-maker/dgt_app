import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/models/learning_lesson_model.dart';
import 'learning_lesson_api_service.dart';

final learningLessonRepositoryProvider = Provider<LearningLessonRepository>(
  (ref) => LearningLessonRepository(LearningLessonApiService()),
);

class LearningLessonRepository {
  const LearningLessonRepository(this._apiService);

  final LearningLessonApiService _apiService;

  Future<LearningLessonBundle> fetchLessons({
    required int gradeId,
    required int subjectId,
    int page = 1,
    int limit = 10,
    int? offset,
  }) async {
    final rawResponse = await _apiService.fetchLessons(
      gradeId: gradeId,
      subjectId: subjectId,
      page: page,
      limit: limit,
      offset: offset,
    );

    final (rawList, resolvedPage, hasMore) = _extractDataAndPagination(
      rawResponse,
      page,
      limit,
    );

    final lessons = rawList
        .map(_tryParse)
        .whereType<LearningLessonModel>()
        .toList(growable: false);

    return LearningLessonBundle(
      lessons: lessons,
      page: resolvedPage,
      hasMore: hasMore,
    );
  }

  (List<Object?>, int, bool) _extractDataAndPagination(
    Object? rawResponse,
    int requestedPage,
    int requestedLimit,
  ) {
    if (rawResponse is List) {
      final hasMore = rawResponse.length >= requestedLimit;
      return (rawResponse, requestedPage, hasMore);
    }

    if (rawResponse is! Map<String, dynamic>) {
      return (const <Object?>[], requestedPage, false);
    }

    List<Object?> list = const <Object?>[];
    for (final key in const ['data', 'lessons', 'items', 'results', 'rows']) {
      final val = rawResponse[key];
      if (val is List) {
        list = val.cast<Object?>();
        break;
      }
    }

    int page = requestedPage;
    final metaObj =
        (rawResponse['meta'] ?? rawResponse['pagination'])
            as Map<String, dynamic>?;
    final pageVal =
        metaObj?['page'] ??
        metaObj?['currentPage'] ??
        rawResponse['page'] ??
        rawResponse['currentPage'];
    if (pageVal is num) page = pageVal.toInt();

    bool hasMore = false;
    final directHasMore = metaObj?['hasMore'] ?? rawResponse['hasMore'];
    if (directHasMore is bool) {
      hasMore = directHasMore;
    } else {
      final totalVal =
          metaObj?['total'] ??
          metaObj?['totalItems'] ??
          rawResponse['total'] ??
          rawResponse['totalItems'];
      final totalPagesVal =
          metaObj?['totalPages'] ??
          metaObj?['lastPage'] ??
          rawResponse['totalPages'] ??
          rawResponse['lastPage'];
      if (totalPagesVal is num) {
        hasMore = page < totalPagesVal.toInt();
      } else if (totalVal is num) {
        hasMore = (page * requestedLimit) < totalVal.toInt();
      } else {
        hasMore = list.length >= requestedLimit;
      }
    }

    return (list, page, hasMore);
  }

  LearningLessonModel? _tryParse(Object? value) {
    try {
      return LearningLessonModel.fromJson(value);
    } on FormatException {
      return null;
    }
  }
}
