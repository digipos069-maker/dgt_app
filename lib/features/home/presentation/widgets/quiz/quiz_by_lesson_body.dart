import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dgt_app/core/constants/app_sizes.dart';
import 'package:dgt_app/core/utils/app_exception.dart';
import 'package:dgt_app/localization/app_localizations.dart';
import 'package:dgt_app/theme/app_colors.dart';
import 'package:dgt_app/features/auth/application/auth_controller.dart';
import 'package:dgt_app/features/home/application/quiz_by_lesson_controller.dart';
import 'package:dgt_app/features/home/application/quiz_controller.dart';
import 'package:dgt_app/features/home/domain/models/quiz_by_lesson_model.dart';
import 'package:dgt_app/features/home/domain/models/quiz_models.dart';
import 'package:dgt_app/features/home/domain/models/quiz_submission_result.dart';
import 'lesson_quiz_section.dart';
import 'quiz_button.dart';

class QuizByLessonBody extends ConsumerStatefulWidget {
  const QuizByLessonBody({
    required this.lessonId,
    this.size = 15,
    this.onBack,
    super.key,
  });

  final int lessonId;
  final int size;
  final VoidCallback? onBack;

  @override
  ConsumerState<QuizByLessonBody> createState() => _QuizByLessonBodyState();
}

class _QuizByLessonBodyState extends ConsumerState<QuizByLessonBody> {
  // Multiple choice answers (questionId -> optionId)
  final Map<String, String> _answers = {};

  // Matching answers (questionId -> (stemId -> optionId))
  final Map<String, Map<String, String>> _matchingAnswers = {};

  // Drag & drop answers (questionId -> droppedItem)
  final Map<String, String?> _dragAnswers = {};

  final Set<String> _submittingQuestions = {};
  final Set<String> _submittedQuestions = {};
  final Map<String, QuizAnswerFeedback> _answerFeedback = {};

  QuizByLessonArgs get _args =>
      QuizByLessonArgs(lessonId: widget.lessonId, size: widget.size);

  Future<void> _refresh() async {
    ref.invalidate(quizByLessonProvider(_args));
    try {
      await ref.read(quizByLessonProvider(_args).future);
    } catch (_) {}
  }

  Future<void> _submitQuestion(QuizQuestionModel question) async {
    switch (question.type) {
      case QuizType.matching:
        _submitMatchingQuestion(question);
        break;
      case QuizType.dragAndDrop:
        _submitDragAndDropQuestion(question);
        break;
      case QuizType.multipleChoice:
        await _submitMultipleChoiceQuestion(question);
        break;
    }
  }

  void _submitMatchingQuestion(QuizQuestionModel question) {
    final matches = _matchingAnswers[question.id] ?? {};
    final matchingData = question.matchingData;
    if (matchingData == null) return;

    if (matches.length < matchingData.stems.length) {
      _showQuizSnackBar(
        context.l10n.text('quizSelectAnswer'),
        isError: true,
      );
      return;
    }

    final isCorrect = matchingData.areAllMatchesCorrect(matches);
    setState(() {
      if (isCorrect) {
        _submittedQuestions.add(question.id);
      }
      _answerFeedback[question.id] = QuizAnswerFeedback(isCorrect: isCorrect);
    });

    _showQuizSnackBar(
      isCorrect
          ? context.l10n.text('quizCorrect')
          : context.l10n.text('quizIncorrect'),
      isError: !isCorrect,
    );
  }

  void _submitDragAndDropQuestion(QuizQuestionModel question) {
    final dropped = _dragAnswers[question.id];
    final dragData = question.dragAndDropData;
    if (dragData == null) return;

    if (dropped == null || dropped.isEmpty) {
      _showQuizSnackBar(
        context.l10n.text('quizSelectAnswer'),
        isError: true,
      );
      return;
    }

    final isCorrect = dragData.isCorrect(dropped);
    setState(() {
      if (isCorrect) {
        _submittedQuestions.add(question.id);
      }
      _answerFeedback[question.id] = QuizAnswerFeedback(
        isCorrect: isCorrect,
        selectedAnswer: dropped,
        correctAnswer: dragData.correct,
      );
    });

    _showQuizSnackBar(
      isCorrect
          ? context.l10n.text('quizCorrect')
          : context.l10n.text('quizIncorrect'),
      isError: !isCorrect,
    );
  }

  Future<void> _submitMultipleChoiceQuestion(QuizQuestionModel question) async {
    final selectedOptionId = _answers[question.id];
    if (selectedOptionId == null) {
      _showQuizSnackBar(
        context.l10n.text('quizSelectAnswer'),
        isError: true,
      );
      return;
    }

    final selectedOption = question.options.firstWhere(
      (opt) => opt.id == selectedOptionId,
      orElse: () => QuizOptionModel(id: selectedOptionId, labelKey: selectedOptionId),
    );

    final quizId = question.quizId ?? int.tryParse(question.id);
    final authState = ref.read(authControllerProvider);
    final isAuthenticated = switch (authState) {
      AsyncData(:final value) => (value?.token?.isNotEmpty ?? false),
      _ => false,
    };

    setState(() => _submittingQuestions.add(question.id));

    final defaultSubmitErrorMessage =
        context.l10n.text('quizSubmitFailedMessage');
    QuizSubmissionResult? result;
    String? errorMessage;

    if (isAuthenticated && quizId != null) {
      try {
        result = await ref
            .read(quizSubmissionControllerProvider)
            .submitAnswer(
              quizId: quizId,
              selectedAnswer: selectedOption.labelKey,
            );
      } on AppException catch (e) {
        errorMessage = e.message;
      } catch (_) {
        errorMessage = defaultSubmitErrorMessage;
      } finally {
        if (mounted) {
          setState(() => _submittingQuestions.remove(question.id));
        }
      }
    } else {
      if (mounted) {
        setState(() => _submittingQuestions.remove(question.id));
      }
    }

    if (!mounted) return;

    // Determine correctness either from backend API or question's correctAnswer payload
    bool isCorrect;
    String? correctOptionId;

    if (result != null) {
      isCorrect = result.isCorrect ?? false;
      correctOptionId = _findCorrectOptionId(question, result.correctAnswer);
    } else if (question.correctAnswer != null && question.correctAnswer!.isNotEmpty) {
      // Local check against quizData.correct
      final normalizedUserAns = _normalizeAnswer(selectedOption.labelKey);
      final normalizedCorrect = _normalizeAnswer(question.correctAnswer!);
      isCorrect = normalizedUserAns == normalizedCorrect ||
          selectedOption.id.toUpperCase() == question.correctAnswer!.trim().toUpperCase();
      correctOptionId = _findCorrectOptionId(question, question.correctAnswer!);
    } else {
      // Fallback if submission failed and no local answer available
      _showQuizSnackBar(
        errorMessage ?? context.l10n.text('quizSubmitFailedMessage'),
        isError: true,
      );
      return;
    }

    setState(() {
      _submittedQuestions.add(question.id);
      _answerFeedback[question.id] = QuizAnswerFeedback(
        isCorrect: isCorrect,
        selectedAnswer: selectedOptionId,
        correctAnswer: isCorrect ? selectedOptionId : correctOptionId,
      );
    });

    _showQuizSnackBar(
      isCorrect
          ? context.l10n.text('quizCorrect')
          : context.l10n.text('quizIncorrect'),
      isError: !isCorrect,
    );
  }

  String? _findCorrectOptionId(
    QuizQuestionModel question,
    String? correctAnswer,
  ) {
    if (correctAnswer == null || correctAnswer.isEmpty) return null;
    final normalized = _normalizeAnswer(correctAnswer);

    for (final option in question.options) {
      if (_normalizeAnswer(option.labelKey) == normalized ||
          option.id.toUpperCase() == correctAnswer.trim().toUpperCase()) {
        return option.id;
      }
    }
    return null;
  }

  String _normalizeAnswer(String answer) {
    return answer.trim().replaceAll(RegExp(r'\s+'), '');
  }

  void _showQuizSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    final theme = Theme.of(context);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? theme.colorScheme.error : null,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final quizState = ref.watch(quizByLessonProvider(_args));
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.l10n.text('homeQuizzes'),
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        leading: widget.onBack != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: widget.onBack,
              )
            : null,
        elevation: 0,
        backgroundColor: theme.colorScheme.surface,
        surfaceTintColor: Colors.transparent,
      ),
      body: quizState.when(
        loading: () => const _QuizLoadingView(),
        error: (error, _) => _QuizErrorView(
          errorMessage: error is AppException
              ? error.message
              : context.l10n.text('quizSubmitFailedMessage'),
          onRetry: _refresh,
        ),
        data: (response) {
          final quizzes = response.quizzes;
          final lesson = response.lesson;

          return RefreshIndicator(
            color: AppColors.brandButton,
            onRefresh: _refresh,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.spacing16,
                vertical: AppSizes.spacing16,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header card with lesson information
                      if (lesson != null)
                        _LessonHeaderCard(
                          lesson: lesson,
                          totalQuestions: quizzes.length,
                          totalAvailable: response.totalAvailable,
                        ),
                      const SizedBox(height: AppSizes.spacing16),

                      // Progress Tracker Card
                      if (quizzes.isNotEmpty)
                        _QuizProgressCard(
                          totalQuestions: quizzes.length,
                          submittedCount: _submittedQuestions.length,
                          correctCount: _answerFeedback.values
                              .where((fb) => fb.isCorrect)
                              .length,
                        ),
                      const SizedBox(height: AppSizes.spacing16),

                      // List ONLY quiz using the project's quiz component
                      LessonQuizSection(
                        quizTitleKey: 'lessonQuizTitle',
                        quizSubtitleKey: lesson?.description.isNotEmpty == true
                            ? lesson!.description
                            : 'homeContinueDescription',
                        questions: quizzes,
                        answers: _answers,
                        onChanged: (questionId, optionId) {
                          setState(() {
                            _answers[questionId] = optionId;
                            _submittedQuestions.remove(questionId);
                            _answerFeedback.remove(questionId);
                          });
                        },
                        matchingAnswers: _matchingAnswers,
                        onMatchingChanged: (questionId, matches) {
                          setState(() {
                            _matchingAnswers[questionId] = matches;
                            _submittedQuestions.remove(questionId);
                            _answerFeedback.remove(questionId);
                          });
                        },
                        dragAnswers: _dragAnswers,
                        onDragChanged: (questionId, droppedItem) {
                          setState(() {
                            _dragAnswers[questionId] = droppedItem;
                            _submittedQuestions.remove(questionId);
                            _answerFeedback.remove(questionId);
                          });
                        },
                        submittingQuestions: _submittingQuestions,
                        submittedQuestions: _submittedQuestions,
                        answerFeedback: _answerFeedback,
                        onSubmit: _submitQuestion,
                      ),
                      const SizedBox(height: AppSizes.spacing32),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _LessonHeaderCard extends StatelessWidget {
  const _LessonHeaderCard({
    required this.lesson,
    required this.totalQuestions,
    required this.totalAvailable,
  });

  final QuizLessonInfo lesson;
  final int totalQuestions;
  final int totalAvailable;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final subjectName = lesson.subject?.localizedName(locale);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.6),
        ),
      ),
      padding: const EdgeInsets.all(AppSizes.spacing16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (lesson.grade != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.spacing8,
                    vertical: AppSizes.spacing4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.brandButton.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppSizes.cardRadius),
                  ),
                  child: Text(
                    'Grade ${lesson.grade!.number}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppColors.brandButton,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: AppSizes.spacing8),
              ],
              if (subjectName != null && subjectName.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.spacing8,
                    vertical: AppSizes.spacing4,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppSizes.cardRadius),
                  ),
                  child: Text(
                    subjectName,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.secondary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: AppSizes.spacing8),
              ],
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.spacing8,
                  vertical: AppSizes.spacing4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.brandButton,
                  borderRadius: BorderRadius.circular(AppSizes.cardRadius),
                ),
                child: Text(
                  '$totalQuestions Quizzes',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.spacing12),
          Text(
            lesson.title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: theme.colorScheme.onSurface,
            ),
          ),
          if (lesson.description.isNotEmpty) ...[
            const SizedBox(height: AppSizes.spacing4),
            Text(
              lesson.description,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _QuizProgressCard extends StatelessWidget {
  const _QuizProgressCard({
    required this.totalQuestions,
    required this.submittedCount,
    required this.correctCount,
  });

  final int totalQuestions;
  final int submittedCount;
  final int correctCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = totalQuestions > 0 ? (submittedCount / totalQuestions) : 0.0;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.6),
        ),
      ),
      padding: const EdgeInsets.all(AppSizes.spacing16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progress: $submittedCount / $totalQuestions',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              Text(
                'Score: $correctCount / $submittedCount',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.brandButton,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.spacing8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              backgroundColor: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.brandButton),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuizLoadingView extends StatelessWidget {
  const _QuizLoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.brandButton),
          ),
          SizedBox(height: AppSizes.spacing16),
          Text('Loading quizzes...'),
        ],
      ),
    );
  }
}

class _QuizErrorView extends StatelessWidget {
  const _QuizErrorView({
    required this.errorMessage,
    required this.onRetry,
  });

  final String errorMessage;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.spacing24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
            const SizedBox(height: AppSizes.spacing16),
            Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
            const SizedBox(height: AppSizes.spacing24),
            QuizButton(
              onPressed: onRetry,
              label: context.l10n.text('quizTryAgain'),
              icon: Icons.refresh,
            ),
          ],
        ),
      ),
    );
  }
}
