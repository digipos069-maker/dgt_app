import 'package:flutter/material.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../localization/app_localizations.dart';
import 'ai_tutor_avatar.dart';

/// Empty state: greeting plus tappable starter questions.
class AiTutorWelcome extends StatelessWidget {
  const AiTutorWelcome({
    required this.isLessonMode,
    required this.onSuggestionTap,
    required this.onPickLesson,
    this.lessonTitle,
    super.key,
  });

  final bool isLessonMode;
  final String? lessonTitle;
  final ValueChanged<String> onSuggestionTap;
  final VoidCallback onPickLesson;

  static const _lessonSuggestionKeys = [
    'aiTutorSuggestionExplain',
    'aiTutorSuggestionExample',
    'aiTutorSuggestionRemember',
    'aiTutorSuggestionPractice',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return ListView(
      padding: const EdgeInsets.all(AppSizes.spacing24),
      children: [
        const SizedBox(height: AppSizes.spacing16),
        const Center(child: AiTutorAvatar(size: 64)),
        const SizedBox(height: AppSizes.spacing16),
        Text(
          l10n.text('aiTutorWelcomeTitle'),
          textAlign: TextAlign.center,
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: AppSizes.spacing8),
        if (isLessonMode && (lessonTitle?.isNotEmpty ?? false)) ...[
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.spacing12,
                vertical: AppSizes.spacing4,
              ),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppSizes.cardRadius),
              ),
              child: Text(
                lessonTitle!,
                textAlign: TextAlign.center,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSizes.spacing8),
        ],
        Text(
          l10n.text(isLessonMode ? 'aiTutorWelcomeLesson' : 'aiTutorWelcomeGeneral'),
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppSizes.spacing24),
        if (isLessonMode)
          Wrap(
            alignment: WrapAlignment.center,
            spacing: AppSizes.spacing8,
            runSpacing: AppSizes.spacing8,
            children: [
              for (final key in _lessonSuggestionKeys)
                ActionChip(
                  avatar: Icon(
                    Icons.lightbulb_outline,
                    size: 18,
                    color: theme.colorScheme.primary,
                  ),
                  label: Text(l10n.text(key)),
                  onPressed: () => onSuggestionTap(l10n.text(key)),
                ),
            ],
          )
        else
          // A lesson is required before chatting.
          Center(
            child: FilledButton.icon(
              onPressed: onPickLesson,
              icon: const Icon(Icons.menu_book_rounded),
              label: Text(l10n.text('aiTutorPickLessonTitle')),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.spacing24,
                  vertical: AppSizes.spacing12,
                ),
              ),
            ),
          ),
        const SizedBox(height: AppSizes.spacing24),
        Text(
          l10n.text('aiTutorDisclaimer'),
          textAlign: TextAlign.center,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
