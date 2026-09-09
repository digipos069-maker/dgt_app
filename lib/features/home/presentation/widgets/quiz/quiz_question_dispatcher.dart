import 'package:flutter/material.dart';

import 'package:dgt_app/features/home/domain/models/quiz_models.dart';
import 'drag_and_drop_quiz_widget.dart';
import 'matching_quiz_widget.dart';
import 'multiple_choice_quiz_widget.dart';

class QuizQuestionDispatcher extends StatelessWidget {
  const QuizQuestionDispatcher({
    required this.number,
    required this.question,
    required this.selectedAnswer,
    required this.onAnswerChanged,
    this.matchingMatches,
    this.onMatchingChanged,
    this.droppedValue,
    this.onDroppedChanged,
    this.onSubmit,
    this.isSubmitting = false,
    this.isSubmitted = false,
    this.isCorrect,
    this.correctAnswer,
    super.key,
  });

  final int number;
  final QuizQuestionModel question;

  // Multiple choice
  final String? selectedAnswer;
  final ValueChanged<String>? onAnswerChanged;

  // Matching
  final Map<String, String>? matchingMatches;
  final ValueChanged<Map<String, String>>? onMatchingChanged;

  // Drag & drop
  final String? droppedValue;
  final ValueChanged<String?>? onDroppedChanged;

  // Generic submit callback
  final VoidCallback? onSubmit;
  final bool isSubmitting;
  final bool isSubmitted;
  final bool? isCorrect;
  final String? correctAnswer;

  @override
  Widget build(BuildContext context) {
    switch (question.type) {
      case QuizType.matching:
        final matchingData = question.matchingData;
        if (matchingData == null) {
          return const SizedBox.shrink();
        }
        return MatchingQuizWidget(
          number: number,
          data: matchingData,
          initialMatches: matchingMatches,
          onMatchesChanged: onMatchingChanged,
          onSubmit: (_) => onSubmit?.call(),
          isSubmitting: isSubmitting,
          isSubmitted: isSubmitted,
          showValidation: isCorrect != null,
        );

      case QuizType.dragAndDrop:
        final dragData = question.dragAndDropData;
        if (dragData == null) {
          return const SizedBox.shrink();
        }
        return DragAndDropQuizWidget(
          number: number,
          data: dragData,
          initialDroppedValue: droppedValue,
          onDroppedChanged: onDroppedChanged,
          onSubmit: (_) => onSubmit?.call(),
          isSubmitting: isSubmitting,
          isSubmitted: isSubmitted,
          showValidation: isCorrect != null,
        );

      case QuizType.multipleChoice:
        return MultipleChoiceQuizWidget(
          number: number,
          question: question,
          selectedOption: selectedAnswer,
          onChanged: onAnswerChanged,
          onSubmit: onSubmit,
          isSubmitting: isSubmitting,
          isSubmitted: isSubmitted,
          isCorrect: isCorrect,
          correctOptionId: correctAnswer,
        );
    }
  }
}
