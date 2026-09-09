import 'package:flutter/material.dart';

import 'package:dgt_app/core/constants/app_sizes.dart';
import 'package:dgt_app/features/home/domain/models/quiz_models.dart';
import 'package:dgt_app/localization/app_localizations.dart';
import 'quiz_question_dispatcher.dart';

class QuizAnswerFeedback {
  const QuizAnswerFeedback({
    required this.isCorrect,
    this.selectedAnswer,
    this.correctAnswer,
  });

  final bool isCorrect;
  final String? selectedAnswer;
  final String? correctAnswer;
}

class LessonQuizSection extends StatelessWidget {
  const LessonQuizSection({
    required this.quizTitleKey,
    required this.quizSubtitleKey,
    required this.questions,
    required this.answers,
    required this.onChanged,
    required this.submittingQuestions,
    required this.submittedQuestions,
    required this.answerFeedback,
    required this.onSubmit,
    this.matchingAnswers = const {},
    this.onMatchingChanged,
    this.dragAnswers = const {},
    this.onDragChanged,
    super.key,
  });

  final String quizTitleKey;
  final String quizSubtitleKey;
  final List<QuizQuestionModel> questions;

  // Multiple choice answers (questionId -> optionId)
  final Map<String, String> answers;
  final void Function(String questionId, String optionId) onChanged;

  // Matching answers (questionId -> (stemId -> optionId))
  final Map<String, Map<String, String>> matchingAnswers;
  final void Function(String questionId, Map<String, String> matches)?
      onMatchingChanged;

  // Drag & drop answers (questionId -> droppedItem)
  final Map<String, String?> dragAnswers;
  final void Function(String questionId, String? droppedItem)? onDragChanged;

  final Set<String> submittingQuestions;
  final Set<String> submittedQuestions;
  final Map<String, QuizAnswerFeedback> answerFeedback;
  final ValueChanged<QuizQuestionModel> onSubmit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.7),
          width: 1.5,
        ),
      ),
      padding: const EdgeInsets.all(AppSizes.spacing16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.quiz_outlined,
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: AppSizes.spacing12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.text(quizTitleKey),
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.secondary,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: AppSizes.spacing4),
                    Text(
                      context.l10n.text(quizSubtitleKey),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.spacing24),
          if (questions.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSizes.spacing32),
              child: Center(
                child: Text(
                  context.l10n.text('noQuizForLesson'),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            )
          else
            for (final (index, question) in questions.indexed) ...[
              if (index > 0)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: AppSizes.spacing24,
                  ),
                  child: Divider(
                    height: 1,
                    color: theme.colorScheme.outlineVariant.withValues(
                      alpha: 0.65,
                    ),
                  ),
                ),
              QuizQuestionDispatcher(
                number: index + 1,
                question: question,
                selectedAnswer: answers[question.id],
                onAnswerChanged: (optionId) => onChanged(question.id, optionId),
                matchingMatches: matchingAnswers[question.id],
                onMatchingChanged: (matches) =>
                    onMatchingChanged?.call(question.id, matches),
                droppedValue: dragAnswers[question.id],
                onDroppedChanged: (item) =>
                    onDragChanged?.call(question.id, item),
                isSubmitting: submittingQuestions.contains(question.id),
                isSubmitted: submittedQuestions.contains(question.id),
                isCorrect: answerFeedback[question.id]?.isCorrect,
                correctAnswer: answerFeedback[question.id]?.correctAnswer,
                onSubmit: () => onSubmit(question),
              ),
            ],
        ],
      ),
    );
  }
}
