import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/models/learning_lesson_model.dart';
import 'learning_lesson_api_service.dart';

final learningLessonRepositoryProvider = Provider<LearningLessonRepository>(
  (ref) => LearningLessonRepository(LearningLessonApiService()),
);

class LearningLessonRepository {
  const LearningLessonRepository(this._apiService);

  final LearningLessonApiService _apiService;

  Future<List<LearningLessonModel>> fetchLessons({
    required int gradeId,
    required int subjectId,
  }) async {
    final data = await _apiService.fetchLessons(
      gradeId: gradeId,
      subjectId: subjectId,
    );

    return data
        .map(_tryParse)
        .whereType<LearningLessonModel>()
        .toList(growable: false);
  }

  LearningLessonModel? _tryParse(Object? value) {
    try {
      return LearningLessonModel.fromJson(value);
    } on FormatException {
      return null;
    }
  }
}
