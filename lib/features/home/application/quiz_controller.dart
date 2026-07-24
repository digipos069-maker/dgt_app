import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/app_exception.dart';
import '../../auth/application/auth_controller.dart';
import '../data/quiz_repository.dart';
import '../domain/models/quiz_submission_result.dart';

final quizSubmissionControllerProvider = Provider<QuizSubmissionController>((
  ref,
) {
  final authState = ref.watch(authControllerProvider);
  final token = switch (authState) {
    AsyncData(:final value) => value?.token,
    _ => null,
  };
  return QuizSubmissionController(
    repository: ref.watch(quizRepositoryProvider),
    token: token,
  );
});

class QuizSubmissionController {
  const QuizSubmissionController({
    required QuizRepository repository,
    required String? token,
  }) : _repository = repository,
       _token = token;

  final QuizRepository _repository;
  final String? _token;

  Future<QuizSubmissionResult> submitAnswer({
    required int quizId,
    required String selectedAnswer,
  }) {
    final token = _token;
    if (token == null || token.isEmpty) {
      throw const AppException('Authentication is required');
    }
    return _repository.submitAnswer(
      quizId: quizId,
      selectedAnswer: selectedAnswer,
      token: token,
    );
  }
}
