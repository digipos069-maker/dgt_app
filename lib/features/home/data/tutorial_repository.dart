import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/models/lesson_model.dart';
import '../domain/models/tutorial_detail_model.dart';
import '../domain/models/tutorial_model.dart';
import 'tutorial_api_service.dart';

final tutorialRepositoryProvider = Provider<TutorialRepository>(
  (ref) => TutorialRepository(TutorialApiService()),
);

class TutorialRepository {
  const TutorialRepository(this._apiService);

  final TutorialApiService _apiService;

  Future<CourseLessonBundle> fetchTutorials({
    required int subjectId,
    required int gradeId,
    required int lessonId,
    required String token,
    int page = 1,
    int limit = 10,
  }) async {
    final rawResponse = await _apiService.fetchTutorials(
      subjectId: subjectId,
      gradeId: gradeId,
      lessonId: lessonId,
      token: token,
      page: page,
      limit: limit,
    );

    final (rawList, resolvedPage, hasMore) = _extractDataAndPagination(
      rawResponse,
      page,
      limit,
    );

    final tutorials =
        rawList
            .map(_tryParse)
            .whereType<TutorialModel>()
            .toList(growable: false)
          ..sort((first, second) => first.orderId.compareTo(second.orderId));

    return CourseLessonBundle(
      courseId: lessonId.toString(),
      appBarTitleKey: 'lessonsTitle',
      titleKey: _subjectTitleKey(subjectId),
      descriptionKey: 'gradeCardDescription',
      page: resolvedPage,
      hasMore: hasMore,
      lessons: [
        for (var index = 0; index < tutorials.length; index++)
          _toLesson(tutorials[index], (page - 1) * limit + index, lessonId),
      ],
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
    for (final key in const ['data', 'tutorials', 'items', 'results', 'rows']) {
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

  Future<LessonDetailModel> fetchTutorialDetail({
    required String courseId,
    required String slug,
    required String token,
  }) async {
    final data = await _apiService.fetchTutorialBySlug(
      slug: slug,
      token: token,
    );
    final tutorial = TutorialDetailModel.fromJson(data);
    final parsedQuestions = tutorial.quizzes
        .map((quiz) => quiz.toQuizQuestionModel())
        .where(
          (q) =>
              q.questionKey.isNotEmpty ||
              q.matchingData != null ||
              q.dragAndDropData != null,
        )
        .toList(growable: false);
    final questions =
        parsedQuestions.isNotEmpty ? parsedQuestions : _fallbackQuestions;

    return LessonDetailModel(
      courseId: courseId,
      lessonId: tutorial.id > 0 ? tutorial.id.toString() : slug,
      titleKey: tutorial.title.isNotEmpty
          ? tutorial.title
          : 'lessonLinearEquations',
      subjectKey: _subjectTitleKey(tutorial.subjectId),
      moduleKey: 'lessonDetailModuleOne',
      descriptionKey: tutorial.description.isNotEmpty
          ? tutorial.description
          : 'lessonLinearEquationsDescription',
      durationLabel: '12:45',
      quizTitleKey: 'lessonQuizTitle',
      quizSubtitleKey: 'lessonQuizSubtitleLinear',
      questions: questions,
      mainVideoUrl: tutorial.mainVideoUrl,
      videoThumbnail: tutorial.videoThumbnail,
    );
  }

  TutorialModel? _tryParse(Object? value) {
    try {
      return TutorialModel.fromJson(value);
    } on FormatException {
      return null;
    }
  }

  LessonModel _toLesson(TutorialModel tutorial, int index, int lessonId) {
    final locked = tutorial.isLocked;
    final hasVideo = tutorial.mainVideoUrl.isNotEmpty;

    return LessonModel(
      courseId: lessonId.toString(),
      id: tutorial.id > 0 ? tutorial.id.toString() : 'tutorial-${index + 1}',
      titleKey: 'lessonsTitle',
      title: tutorial.title,
      description: tutorial.description,
      mainVideoUrl: tutorial.mainVideoUrl,
      videoThumbnail: tutorial.videoThumbnail,
      slug: tutorial.slug,
      orderId: tutorial.orderId,
      type: locked
          ? LessonType.locked
          : hasVideo
          ? LessonType.video
          : LessonType.reading,
      durationMinutes: 12 + (index * 3),
      isCompleted: tutorial.isCompleted,
    );
  }

  String _subjectTitleKey(int subjectId) => switch (subjectId) {
    2 => 'subjectPhysics',
    3 => 'subjectChemistry',
    4 => 'subjectBiology',
    _ => 'subjectMath',
  };

  static const _fallbackQuestions = [
    QuizQuestionModel(
      id: 'q1',
      questionKey: 'quizLinearQuestionOne',
      options: [
        QuizOptionModel(id: 'A', labelKey: 'quizLinearQ1A'),
        QuizOptionModel(id: 'B', labelKey: 'quizLinearQ1B'),
        QuizOptionModel(id: 'C', labelKey: 'quizLinearQ1C'),
        QuizOptionModel(id: 'D', labelKey: 'quizLinearQ1D'),
      ],
    ),
    QuizQuestionModel.matching(
      id: 'q2_matching',
      matchingData: MatchingQuizData(
        stems: [
          QuizStem(id: 's1', text: 'Variable x'),
          QuizStem(id: 's2', text: 'Constant 5'),
          QuizStem(id: 's3', text: 'Coefficient 2'),
        ],
        options: [
          MatchingOption(id: 'o1', text: 'Unknown value to solve'),
          MatchingOption(id: 'o2', text: 'Fixed numeric value'),
          MatchingOption(id: 'o3', text: 'Multiplicative factor of x'),
        ],
        description: 'Match algebraic terms with their definitions',
        correctMatches: {
          's1': 'o1',
          's2': 'o2',
          's3': 'o3',
        },
      ),
    ),
    QuizQuestionModel.dragAndDrop(
      id: 'q3_drag_drop',
      dragAndDropData: DragAndDropQuizData(
        correct: '2H₂O',
        draggables: [
          '2H₂O',
          'H₂',
          'O₂',
        ],
        droppableId: 'water-molecule',
        prompt: 'Drag the balanced water molecule product into the slot:',
      ),
    ),
  ];
}
