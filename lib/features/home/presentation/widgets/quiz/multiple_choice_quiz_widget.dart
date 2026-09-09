import 'package:flutter/material.dart';

import 'package:dgt_app/core/constants/app_sizes.dart';
import 'package:dgt_app/core/widgets/mixed_latex_text.dart';
import 'package:dgt_app/features/home/domain/models/quiz_models.dart';
import 'package:dgt_app/localization/app_localizations.dart';
import 'package:dgt_app/theme/app_colors.dart';
import 'quiz_button.dart';

enum QuizOptionVisualStatus { neutral, correct, incorrect }

class MultipleChoiceQuizWidget extends StatelessWidget {
  const MultipleChoiceQuizWidget({
    required this.number,
    required this.question,
    required this.selectedOption,
    required this.onChanged,
    this.onSubmit,
    this.isSubmitting = false,
    this.isSubmitted = false,
    this.isCorrect,
    this.correctOptionId,
    super.key,
  });

  final int number;
  final QuizQuestionModel question;
  final String? selectedOption;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onSubmit;
  final bool isSubmitting;
  final bool isSubmitted;
  final bool? isCorrect;
  final String? correctOptionId;

  QuizOptionVisualStatus _statusForOption(String optionId) {
    if (isCorrect == null && correctOptionId == null) {
      return QuizOptionVisualStatus.neutral;
    }
    if (correctOptionId == optionId ||
        (isCorrect == true && selectedOption == optionId)) {
      return QuizOptionVisualStatus.correct;
    }
    if (isCorrect == false && selectedOption == optionId) {
      return QuizOptionVisualStatus.incorrect;
    }
    return QuizOptionVisualStatus.neutral;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final questionText = context.l10n.text(question.questionKey);
    final questionPrefix = context.l10n.text('questionPrefix');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MixedLatexText(
          text: questionText,
          prefix: '$questionPrefix$number. ',
          prefixStyle: TextStyle(
            color: theme.colorScheme.secondary,
            fontWeight: FontWeight.w900,
          ),
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppSizes.spacing16),
        LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 620;
            return GridView.count(
              crossAxisCount: isWide ? 2 : 1,
              crossAxisSpacing: AppSizes.spacing12,
              mainAxisSpacing: AppSizes.spacing12,
              mainAxisExtent: 78,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                for (final option in question.options)
                  _OptionCard(
                    option: option,
                    isSelected: selectedOption == option.id,
                    status: _statusForOption(option.id),
                    onTap: isSubmitting ? null : () => onChanged?.call(option.id),
                  ),
              ],
            );
          },
        ),
        const SizedBox(height: AppSizes.spacing16),
        if (onSubmit != null)
          Align(
            alignment: Alignment.centerRight,
            child: QuizButton(
              onPressed: isSubmitting || selectedOption == null ? null : onSubmit,
              isLoading: isSubmitting,
              isCompleted: isSubmitted,
              icon: isSubmitted
                  ? Icons.check_circle_outline
                  : Icons.send_outlined,
              label: context.l10n.text(
                isSubmitted ? 'quizSubmitted' : 'submitQuiz',
              ),
            ),
          ),
      ],
    );
  }
}

class _OptionCard extends StatelessWidget {
  const _OptionCard({
    required this.option,
    required this.isSelected,
    required this.status,
    required this.onTap,
  });

  final QuizOptionModel option;
  final bool isSelected;
  final QuizOptionVisualStatus status;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = switch (status) {
      QuizOptionVisualStatus.correct => AppColors.success,
      QuizOptionVisualStatus.incorrect => AppColors.error,
      QuizOptionVisualStatus.neutral => null,
    };
    final backgroundColor = switch (status) {
      QuizOptionVisualStatus.correct =>
        AppColors.success.withValues(alpha: 0.08),
      QuizOptionVisualStatus.incorrect =>
        AppColors.error.withValues(alpha: 0.08),
      QuizOptionVisualStatus.neutral =>
        isSelected
            ? theme.colorScheme.primary.withValues(alpha: 0.07)
            : theme.colorScheme.surface,
    };

    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(AppSizes.cardRadius),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSizes.cardRadius),
            border: Border.all(
              color:
                  statusColor ??
                  (isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.outlineVariant),
              width: status == QuizOptionVisualStatus.neutral && !isSelected
                  ? 1
                  : 1.5,
            ),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.spacing16,
            vertical: AppSizes.spacing12,
          ),
          child: Row(
            children: [
              _SelectionCircle(isSelected: isSelected, status: status),
              const SizedBox(width: AppSizes.spacing12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MixedLatexText(
                      text: context.l10n.text(option.labelKey),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                    if (status != QuizOptionVisualStatus.neutral) ...[
                      const SizedBox(height: AppSizes.spacing4),
                      Text(
                        context.l10n.text(
                          status == QuizOptionVisualStatus.correct
                              ? 'quizAnswerCorrect'
                              : 'quizAnswerIncorrect',
                        ),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SelectionCircle extends StatelessWidget {
  const _SelectionCircle({required this.isSelected, required this.status});

  final bool isSelected;
  final QuizOptionVisualStatus status;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      QuizOptionVisualStatus.correct => AppColors.success,
      QuizOptionVisualStatus.incorrect => AppColors.error,
      QuizOptionVisualStatus.neutral => Theme.of(context).colorScheme.primary,
    };

    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected ? color : Theme.of(context).colorScheme.outline,
          width: 1.5,
        ),
      ),
      child: status == QuizOptionVisualStatus.correct
          ? Icon(Icons.check, color: color, size: 14)
          : status == QuizOptionVisualStatus.incorrect
          ? Icon(Icons.close, color: color, size: 14)
          : isSelected
          ? Center(
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
            )
          : null,
    );
  }
}
