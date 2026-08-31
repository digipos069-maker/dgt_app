import 'package:dgt_app/features/home/data/learning_lesson_api_service.dart';
import 'package:dgt_app/features/home/domain/models/learning_lesson_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test('sends selected subject and grade query parameters', () async {
    late Uri requestedUri;
    final service = LearningLessonApiService(
      client: MockClient((request) async {
        requestedUri = request.url;
        return http.Response(
          '[{"id":7,"title":"Algebra","description":"Introduction"}]',
          200,
        );
      }),
    );

    final result = await service.fetchLessons(gradeId: 12, subjectId: 1);

    expect(requestedUri.path, '/api/lessons');
    expect(requestedUri.queryParameters['gradeId'], '12');
    expect(requestedUri.queryParameters['subjectId'], '1');
    expect(requestedUri.queryParameters['page'], '1');
    expect(requestedUri.queryParameters['limit'], '10');
    expect(result, isA<List>());
    expect((result as List), hasLength(1));
  });

  test('parses common lesson API field names', () {
    final lesson = LearningLessonModel.fromJson({
      'lessonId': 9,
      'name': 'Motion',
      'shortDescription': 'Force and movement',
      'thumbnailUrl': '/uploads/motion.png',
      'subject': {'id': 2},
      'gradeId': 12,
      'duration': 15,
      'enrolledCount': 30,
    });

    expect(lesson.id, '9');
    expect(lesson.title, 'Motion');
    expect(lesson.subjectId, 2);
    expect(lesson.gradeId, 12);
    expect(lesson.durationMinutes, 15);
    expect(lesson.learnerCount, 30);
  });
}
