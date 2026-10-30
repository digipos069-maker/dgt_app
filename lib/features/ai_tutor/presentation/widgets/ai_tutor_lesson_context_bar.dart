import 'package:flutter/material.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../localization/app_localizations.dart';
import '../../domain/models/ai_tutor_lesson_ref.dart';

/// Strip above the input box: shows the attached lesson (tap to change,
/// ✕ to remove) or a highlighted "Add lesson" chip, since a lesson is required.
class AiTutorLessonContextBar extends StatelessWidget {
  const AiTutorLessonContextBar({
    required this.lesson,
    required this.enabled,
    required this.onPick,
    required this.onDetach,
    super.key,
  });

  final AiTutorLessonRef? lesson;
  final bool enabled;
  final VoidCallback onPick;
  final VoidCallback onDetach;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final lesson = this.lesson;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        AppSizes.spacing12,
        AppSizes.spacing8,
        AppSizes.spacing12,
        0,
      ),
      color: theme.colorScheme.surface,
      child: Align(
        alignment: Alignment.centerLeft,
        child: lesson == null
            ? ActionChip(
                avatar: Icon(Icons.add, size: 18, color: theme.colorScheme.onPrimary),
                label: Text(l10n.text('aiTutorAddLesson')),
                labelStyle: TextStyle(
                  color: theme.colorScheme.onPrimary,
                  fontWeight: FontWeight.w700,
                ),
                backgroundColor: theme.colorScheme.primary,
                side: BorderSide.none,
                onPressed: enabled ? onPick : null,
              )
            : InputChip(
                avatar: Icon(Icons.menu_book_rounded, size: 18, color: theme.colorScheme.primary),
                label: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.sizeOf(context).width * 0.6,
                  ),
                  child: Text(
                    lesson.title.isEmpty ? l10n.text('aiTutorContextLabel') : lesson.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                tooltip: l10n.text('aiTutorContextLabel'),
                backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.08),
                side: BorderSide(color: theme.colorScheme.primary.withValues(alpha: 0.35)),
                onPressed: enabled ? onPick : null,
                onDeleted: enabled ? onDetach : null,
                deleteButtonTooltipMessage: l10n.text('aiTutorRemoveLesson'),
                isEnabled: enabled,
              ),
      ),
    );
  }
}
