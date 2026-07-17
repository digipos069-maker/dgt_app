import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/models/lesson_model.dart';
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
      orderId: tutorial.orderId,
      type: locked
          ? LessonType.locked
          : hasVideo
          ? LessonType.video
          : LessonType.reading,
      durationMinutes: 12 + (index * 3),
      isCompleted: !locked && index < 2,
    );
  }

  String _subjectTitleKey(int subjectId) => switch (subjectId) {
    2 => 'subjectPhysics',
    3 => 'subjectChemistry',
    4 => 'subjectBiology',
    _ => 'subjectMath',
  };
}
