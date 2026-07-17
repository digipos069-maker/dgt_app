import 'dart:convert';

import 'package:dgt_app/features/home/data/tutorial_api_service.dart';
import 'package:dgt_app/features/home/data/tutorial_repository.dart';
import 'package:dgt_app/features/home/domain/models/lesson_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test('sends tutorial filters and bearer token', () async {
    late http.Request capturedRequest;
    final service = TutorialApiService(
      client: MockClient((request) async {
        capturedRequest = request;
        return http.Response('[]', 200);
      }),
    );

    await service.fetchTutorials(
      subjectId: 1,
      gradeId: 12,
      lessonId: 4,
      token: 'session-token',
    );

    expect(capturedRequest.url.path, '/api/tutorials');
    expect(capturedRequest.url.queryParameters['subjectId'], '1');
    expect(capturedRequest.url.queryParameters['gradeId'], '12');
    expect(capturedRequest.url.queryParameters['lessonId'], '4');
    expect(capturedRequest.headers['Authorization'], 'Bearer session-token');
  });

  test(
    'maps API tutorials without changing lesson-list design fields',
    () async {
      final repository = TutorialRepository(
        TutorialApiService(
          client: MockClient((_) async {
            return http.Response.bytes(
              utf8.encode('''[
              {
                "id": 3,
                "title": "ចំនួននិមិត្ត",
                "description": "",
                "mainVideoUrl": "https://media.digital-teachers.com/video.mp4",
                "subjectId": 1,
                "gradeId": 12,
                "orderId": 1,
                "lessonId": 4,
                "videoThumbnail": null,
                "lock": 0
              }
            ]'''),
              200,
              headers: const {
                'content-type': 'application/json; charset=utf-8',
              },
            );
          }),
        ),
      );

      final bundle = await repository.fetchTutorials(
        subjectId: 1,
        gradeId: 12,
        lessonId: 4,
        token: 'session-token',
      );
      final tutorial = bundle.lessons.single;

      expect(bundle.courseId, '4');
      expect(tutorial.id, '3');
      expect(tutorial.title, 'ចំនួននិមិត្ត');
      expect(tutorial.type, LessonType.video);
      expect(tutorial.mainVideoUrl, contains('video.mp4'));
      expect(tutorial.durationMinutes, 12);
      expect(tutorial.isCompleted, isTrue);
    },
  );
}
