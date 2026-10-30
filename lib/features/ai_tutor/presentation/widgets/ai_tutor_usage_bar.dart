import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../localization/app_localizations.dart';
import '../../application/ai_tutor_controller.dart';
import 'ai_tutor_upgrade.dart';

/// Thin bar under the app bar: how much of this month's AI tutor allowance is
/// left and when it resets. Students see a percentage, not raw tokens.
/// Hidden while loading or if usage can't be loaded (the chat still works).
class AiTutorUsageBar extends ConsumerWidget {
  const AiTutorUsageBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usage = ref.watch(aiTutorUsageProvider).value;
    if (usage == null) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final l10n = context.l10n;
    final fraction = usage.remainingFraction;
    final percent = (fraction * 100).round();
    final isLow = fraction < 0.15;
    final barColor = isLow ? theme.colorScheme.error : theme.colorScheme.primary;
    final resetsAt = usage.resetsAt;

    final label = usage.isExhausted
        ? l10n.text('aiTutorUsageEmpty')
        : l10n.text('aiTutorUsageLeft').replaceAll('{percent}', '$percent');
    final resetLabel = resetsAt == null
        ? null
        : l10n.text('aiTutorUsageResets').replaceAll('{date}', formatAiTutorDate(resetsAt));

    return Container(
      color: theme.colorScheme.surface,
      padding: const EdgeInsets.fromLTRB(
        AppSizes.spacing16,
        AppSizes.spacing8,
        AppSizes.spacing8,
        AppSizes.spacing8,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: isLow ? theme.colorScheme.error : theme.colorScheme.onSurface,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    if (resetLabel != null)
                      Text(
                        resetLabel,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: AppSizes.spacing4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppSizes.spacing4),
                  child: LinearProgressIndicator(
                    value: fraction,
                    minHeight: 6,
                    color: barColor,
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  ),
                ),
              ],
            ),
          ),
          if (isLow) ...[
            const SizedBox(width: AppSizes.spacing8),
            TextButton(
              onPressed: () => openAiTutorUpgrade(context),
              child: Text(l10n.text('aiTutorUpgrade')),
            ),
          ],
        ],
      ),
    );
  }
}
