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
  }) async {
    final data = await _apiService.fetchTutorials(
      subjectId: subjectId,
      gradeId: gradeId,
      lessonId: lessonId,
      token: token,
    );
    final tutorials =
        data.map(_tryParse).whereType<TutorialModel>().toList(growable: false)
          ..sort((first, second) => first.orderId.compareTo(second.orderId));

    return CourseLessonBundle(
      courseId: lessonId.toString(),
      appBarTitleKey: 'lessonsTitle',
      titleKey: _subjectTitleKey(subjectId),
      descriptionKey: 'gradeCardDescription',
      lessons: [
        for (var index = 0; index < tutorials.length; index++)
          _toLesson(tutorials[index], index, lessonId),
      ],
    );
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
    final questions = tutorial.quizzes
        .where((quiz) => quiz.question.isNotEmpty && quiz.options.isNotEmpty)
        .map(
          (quiz) => QuizQuestionModel(
            id: quiz.id > 0 ? quiz.id.toString() : quiz.question,
            quizId: quiz.id > 0 ? quiz.id : null,
            questionKey: quiz.question,
            options: [
              for (final (index, option) in quiz.options.indexed)
                QuizOptionModel(
                  id: String.fromCharCode(65 + index),
                  labelKey: option,
                ),
            ],
          ),
        )
        .toList(growable: false);

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
      questions: questions.isNotEmpty ? questions : _fallbackQuestions,
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
    QuizQuestionModel(
      id: 'q2',
      questionKey: 'quizLinearQuestionTwo',
      options: [
        QuizOptionModel(id: 'A', labelKey: 'quizLinearQ2A'),
        QuizOptionModel(id: 'B', labelKey: 'quizLinearQ2B'),
        QuizOptionModel(id: 'C', labelKey: 'quizLinearQ2C'),
        QuizOptionModel(id: 'D', labelKey: 'quizLinearQ2D'),
      ],
    ),
  ];
}
