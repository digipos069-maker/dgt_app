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
                "slug": "tutorial-slug",
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
      expect(tutorial.slug, 'tutorial-slug');
      expect(tutorial.title, 'ចំនួននិមិត្ត');
      expect(tutorial.type, LessonType.video);
      expect(tutorial.mainVideoUrl, contains('video.mp4'));
      expect(tutorial.durationMinutes, 12);
      expect(tutorial.isCompleted, isTrue);
    },
  );

  test('fetches and maps tutorial detail by slug', () async {
    late http.Request capturedRequest;
    final repository = TutorialRepository(
      TutorialApiService(
        client: MockClient((request) async {
          capturedRequest = request;
          return http.Response(
            jsonEncode({
              'id': 3,
              'title': 'Complex numbers',
              'slug': 'complex-numbers',
              'description': '',
              'mainVideoUrl': 'https://media.example.com/lesson.mp4',
              'videoThumbnail': null,
              'subjectId': 1,
              'gradeId': 12,
              'orderId': 1,
              'lessonId': 4,
              'quizzes': [
                {
                  'id': 4,
                  'question': r'What is $\sqrt{-9}$?',
                  'quizData': {
                    'correct': r'$3i$',
                    'options': [r'$3i$', r'$-3i$', '3', '-3'],
                  },
                },
              ],
            }),
            200,
            headers: const {'content-type': 'application/json; charset=utf-8'},
          );
        }),
      ),
    );

    final detail = await repository.fetchTutorialDetail(
      courseId: '4',
      slug: 'complex-numbers',
      token: 'session-token',
    );

    expect(capturedRequest.url.path, '/api/tutorials/slug/complex-numbers');
    expect(capturedRequest.headers['Authorization'], 'Bearer session-token');
    expect(detail.titleKey, 'Complex numbers');
    expect(detail.descriptionKey, 'lessonLinearEquationsDescription');
    expect(detail.mainVideoUrl, contains('lesson.mp4'));
    expect(detail.questions.single.quizId, 4);
    expect(detail.questions.single.questionKey, contains('sqrt'));
    expect(detail.questions.single.options, hasLength(4));
  });

  test('supports quizId and root-level quiz options', () async {
    final repository = TutorialRepository(
      TutorialApiService(
        client: MockClient(
          (_) async => http.Response(
            jsonEncode({
              'id': 7,
              'slug': 'alternate-quiz-shape',
              'quiz': {
                'quizId': 42,
                'question': 'Choose the correct value',
                'options': ['1', '2', '3', '4'],
                'correctAnswer': '3',
              },
            }),
            200,
          ),
        ),
      ),
    );

    final detail = await repository.fetchTutorialDetail(
      courseId: '4',
      slug: 'alternate-quiz-shape',
      token: 'session-token',
    );

    expect(detail.questions.single.quizId, 42);
    expect(detail.questions.single.options, hasLength(4));
  });
}
