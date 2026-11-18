import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:dgt_app/features/home/application/quiz_by_lesson_controller.dart';
import 'package:dgt_app/features/home/application/lesson_controller.dart';
import 'package:dgt_app/features/home/data/quiz_api_service.dart';
import 'package:dgt_app/features/home/data/quiz_repository.dart';
import 'package:dgt_app/features/home/domain/models/quiz_by_lesson_model.dart';
import 'package:dgt_app/features/home/domain/models/lesson_model.dart';
import 'package:dgt_app/features/home/presentation/widgets/quiz/quiz_by_lesson_body.dart';
import 'package:dgt_app/features/home/presentation/widgets/lesson_detail_body.dart';
import 'package:dgt_app/features/home/presentation/widgets/lesson_list_body.dart';
import 'package:dgt_app/localization/app_localizations.dart';

void main() {
  const sampleJson = {
    "success": true,
    "lesson": {
      "id": 10,
      "title": "Lesson 10: Linear Algebra",
      "description": "Introduction to matrices",
      "thumbnail": "https://storage.example.com/thumb.png",
      "orderId": 1,
      "trackType": null,
      "track_type": null,
      "subjectId": 1,
      "gradeId": 12,
      "subject": {
        "id": 1,
        "nameKm": "គណិតវិទ្យា",
        "nameEn": "Mathematics",
      },
      "grade": {
        "id": 12,
        "number": 12,
      },
    },
    "totalAvailable": 32,
    "size": 15,
    "count": 15,
    "quizzes": [
      {
        "id": 105,
        "question": "What is the determinant of a 2x2 identity matrix?",
        "type": "MULTIPLE_CHOICE_TEXT",
        "videoExplainUrl": null,
        "textExplain": "The determinant of I is 1.",
        "quizData": {
          "options": ["0", "1", "-1", "2"],
          "correct": "1",
        },
        "tutorialId": 24,
        "basicContentDetailId": null,
        "createdAt": "2026-03-01T00:00:00.000Z",
        "updatedAt": "2026-03-01T00:00:00.000Z",
        "questionImageUrl": null,
        "tutorial": {
          "id": 24,
          "title": "Matrix Determinants",
          "slug": "matrix-determinants",
          "orderId": 3,
        },
      },
    ],
    "data": [],
  };

  group('QuizByLessonResponse Model', () {
    test('parses sample response correctly', () {
      final response = QuizByLessonResponse.fromJson(sampleJson);

      expect(response.success, isTrue);
      expect(response.totalAvailable, 32);
      expect(response.size, 15);
      expect(response.count, 15);

      final lesson = response.lesson;
      expect(lesson, isNotNull);
      expect(lesson!.id, 10);
      expect(lesson.title, 'Lesson 10: Linear Algebra');
      expect(lesson.description, 'Introduction to matrices');
      expect(lesson.subject?.nameKm, 'គណិតវិទ្យា');
      expect(lesson.subject?.nameEn, 'Mathematics');
      expect(lesson.grade?.number, 12);

      expect(response.quizzes.length, 1);
      final quiz = response.quizzes.first;
      expect(quiz.id, '105');
      expect(quiz.quizId, 105);
      expect(quiz.questionKey, 'What is the determinant of a 2x2 identity matrix?');
      expect(quiz.type, QuizType.multipleChoice);
      expect(quiz.textExplain, 'The determinant of I is 1.');
      expect(quiz.correctAnswer, '1');
      expect(quiz.tutorialTitle, 'Matrix Determinants');
      expect(quiz.options.length, 4);
      expect(quiz.options[0].id, 'A');
      expect(quiz.options[0].labelKey, '0');
      expect(quiz.options[1].id, 'B');
      expect(quiz.options[1].labelKey, '1');
      expect(quiz.options[2].id, 'C');
      expect(quiz.options[2].labelKey, '-1');
      expect(quiz.options[3].id, 'D');
      expect(quiz.options[3].labelKey, '2');
    });

    test('falls back to data alias if quizzes is empty or null', () {
      final dataOnlyJson = {
        "success": true,
        "data": [
          {
            "id": 101,
            "question": "Sample Question",
            "quizData": {"options": ["A", "B"], "correct": "A"},
          }
        ],
      };
      final response = QuizByLessonResponse.fromJson(dataOnlyJson);
      expect(response.quizzes.length, 1);
      expect(response.quizzes.first.id, '101');
    });
  });

  group('QuizApiService & Repository', () {
    test('fetchQuizByLesson sends GET request and returns map', () async {
      final mockClient = MockClient((request) async {
        expect(request.method, 'GET');
        expect(request.url.path, contains('/api/m/quiz-by-lesson/10'));
        expect(request.url.queryParameters['size'], '15');
        return http.Response.bytes(
          utf8.encode(jsonEncode(sampleJson)),
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      });

      final apiService = QuizApiService(client: mockClient);
      final repo = QuizRepository(apiService);

      final result = await repo.getQuizByLesson(lessonId: 10, size: 15);
      expect(result.success, isTrue);
      expect(result.lesson?.title, 'Lesson 10: Linear Algebra');
      expect(result.quizzes.length, 1);
    });
  });

  group('QuizByLessonBody Widget Tests', () {
    testWidgets('renders lesson header, quizzes list and submit button', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final mockResponse = QuizByLessonResponse.fromJson(sampleJson);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            quizByLessonProvider(const QuizByLessonArgs(lessonId: 10, size: 15))
                .overrideWith((ref) => Future.value(mockResponse)),
          ],
          child: const MaterialApp(
            localizationsDelegates: [
              AppLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            home: QuizByLessonBody(lessonId: 10, size: 15),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Check header info
      expect(find.text('Lesson 10: Linear Algebra'), findsOneWidget);
      expect(find.text('Grade 12'), findsOneWidget);
      expect(find.text('1 Quizzes'), findsOneWidget);

      // Check quiz question text
      expect(
        find.textContaining('What is the determinant of a 2x2 identity matrix?'),
        findsOneWidget,
      );

      // Check options
      expect(find.text('0'), findsOneWidget);
      expect(find.text('1'), findsOneWidget);
      expect(find.text('-1'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);

      // Check submit button
      expect(find.text('Submit quiz'), findsOneWidget);

      // Tap on option '1'
      await tester.tap(find.text('1'));
      await tester.pumpAndSettle();

      // Submit quiz
      await tester.tap(find.text('Submit quiz'));
      await tester.pumpAndSettle();

      // Explanation should be shown after submission
      expect(find.text('The determinant of I is 1.'), findsOneWidget);
      expect(find.text('Quiz submitted'), findsOneWidget);
    });

    testWidgets('LessonDetailContent does not show the Final Summary Quiz card', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      const mockDetail = LessonDetailModel(
        courseId: '10',
        lessonId: '10',
        titleKey: 'Lesson 10: Linear Algebra',
        subjectKey: 'math',
        moduleKey: 'algebra',
        descriptionKey: 'Introduction to matrices',
        durationLabel: '15:00',
        quizTitleKey: 'lessonQuizTitle',
        quizSubtitleKey: 'lessonQuizSubtitleLinear',
        questions: [],
      );

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            localizationsDelegates: [AppLocalizations.delegate],
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: LessonDetailContent(
                detail: mockDetail,
                courseId: '10',
                lessonId: '10',
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Final Summary Quiz'), findsNothing);
      expect(find.text('15 Summary Questions'), findsNothing);
    });

    testWidgets('LessonListBody renders Test your knowledge button', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final bundle = CourseLessonBundle(
        courseId: '10',
        appBarTitleKey: 'math',
        titleKey: 'algebra',
        descriptionKey: 'Introduction to algebra',
        hasMore: false,
        lessons: const [
          LessonModel(
            courseId: '10',
            id: '1',
            titleKey: 'lesson 1',
            type: LessonType.reading,
            durationMinutes: 10,
            isCompleted: false,
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            lessonBundleProvider('10').overrideWith(
              (ref) => Future.value(bundle),
            ),
          ],
          child: const MaterialApp(
            localizationsDelegates: [AppLocalizations.delegate],
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: LessonListBody(courseId: '10'),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Test your knowledge'), findsWidgets);
    });
  });
}
