import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/models/quiz_submission_result.dart';
import 'quiz_api_service.dart';

final quizRepositoryProvider = Provider<QuizRepository>(
  (ref) => QuizRepository(QuizApiService()),
);

class QuizRepository {
  const QuizRepository(this._apiService);

  final QuizApiService _apiService;

  Future<QuizSubmissionResult> submitAnswer({
    required int quizId,
    required String selectedAnswer,
    required String token,
  }) async {
    final response = await _apiService.submitQuiz(
      quizId: quizId,
      answer: selectedAnswer,
      token: token,
    );
    return QuizSubmissionResult.fromJson(response);
  }
}
