import 'package:flutter_test/flutter_test.dart';
import 'package:dgt_app/core/constants/api_constants.dart';
import 'package:dgt_app/features/auth/data/grade_api_service.dart';
import 'package:dgt_app/features/auth/data/grade_repository.dart';
import 'package:dgt_app/features/home/data/learning_lesson_api_service.dart';
import 'package:dgt_app/features/home/data/learning_lesson_repository.dart';

void main() {
  test('fetch real production grades through GradeRepository', () async {
    final repo = GradeRepository(GradeApiService());
    final grades = await repo.fetchGrades();
    print('Fetched ' + grades.length.toString() + ' grades');
    for (final g in grades) {
      print('Grade: id=' + g.id.toString() + ', number=' + g.number.toString() + ', name=' + g.name);
    }
    expect(grades.isNotEmpty, true);
  });

  test('fetch real production lessons through LearningLessonRepository', () async {
    final repo = LearningLessonRepository(LearningLessonApiService());
    final bundle = await repo.fetchLessons(gradeId: 12, subjectId: 1);
    print('Fetched ' + bundle.lessons.length.toString() + ' lessons');
    for (final l in bundle.lessons) {
      print('Lesson: id=' + l.id + ', title=' + l.title);
    }
    expect(bundle.lessons.isNotEmpty, true);
  });
}
