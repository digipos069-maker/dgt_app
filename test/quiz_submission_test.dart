import 'dart:convert';

import 'package:dgt_app/features/home/data/quiz_api_service.dart';
import 'package:dgt_app/features/home/data/quiz_repository.dart';
import 'package:dgt_app/features/home/domain/models/quiz_submission_result.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test('submits the selected answer for one quiz', () async {
    late http.Request capturedRequest;
    final repository = QuizRepository(
      QuizApiService(
        client: MockClient((request) async {
          capturedRequest = request;
          return http.Response(
            jsonEncode({
              'success': true,
              'isCorrect': true,
              'correctAnswer': r'$$3i$$',
            }),
            200,
          );
        }),
      ),
    );

    final result = await repository.submitAnswer(
      quizId: 4,
      selectedAnswer: r'$$3i$$',
      token: 'session-token',
    );
    final body = jsonDecode(capturedRequest.body) as Map<String, dynamic>;

    expect(capturedRequest.method, 'POST');
    expect(capturedRequest.url.path, '/api/quiz/submit');
    expect(capturedRequest.headers['Authorization'], 'Bearer session-token');
    expect(
      capturedRequest.headers['Content-Type'],
      contains('application/json'),
    );
    expect(body['quizId'], 4);
    expect(body['answer'], r'$$3i$$');
    expect(result.isCorrect, isTrue);
    expect(result.correctAnswer, r'$$3i$$');
    expect(result.message, isEmpty);
  });

  test('supports a successful response without correctness metadata', () async {
    final repository = QuizRepository(
      QuizApiService(client: MockClient((_) async => http.Response('', 201))),
    );

    final result = await repository.submitAnswer(
      quizId: 5,
      selectedAnswer: '3',
      token: 'session-token',
    );

    expect(result.isCorrect, isNull);
    expect(result.correctAnswer, isEmpty);
    expect(result.message, isEmpty);
  });

  test('does not treat a transport success flag as answer correctness', () {
    final result = QuizSubmissionResult.fromJson({
      'success': true,
      'message': 'Submitted',
    });

    expect(result.isCorrect, isNull);
    expect(result.message, 'Submitted');
  });
}
