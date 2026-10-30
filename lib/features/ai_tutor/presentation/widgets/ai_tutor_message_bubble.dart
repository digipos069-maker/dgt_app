import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/widgets/mixed_latex_text.dart';
import '../../../../localization/app_localizations.dart';
import '../../domain/models/ai_tutor_message.dart';
import 'ai_tutor_avatar.dart';
import 'ai_tutor_rich_text.dart';
import 'ai_tutor_typing_indicator.dart';

/// One chat message. Student questions are right-aligned bubbles; tutor replies
/// are full-width formatted text next to the tutor avatar (ChatGPT-style).
class AiTutorMessageBubble extends StatelessWidget {
  const AiTutorMessageBubble({
    required this.message,
    this.onRetry,
    this.onPickLesson,
    super.key,
  });

  final AiTutorMessage message;
  final VoidCallback? onRetry;

  /// Opens the lesson picker (used by the "choose a lesson first" reply).
  final VoidCallback? onPickLesson;

  @override
  Widget build(BuildContext context) {
    return message.isUser
        ? _UserBubble(message: message)
        : _TutorReply(message: message, onRetry: onRetry, onPickLesson: onPickLesson);
  }
}

class _UserBubble extends StatelessWidget {
  const _UserBubble({required this.message});

  final AiTutorMessage message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(
        top: AppSizes.spacing12,
        bottom: AppSizes.spacing4,
        left: AppSizes.spacing32,
      ),
      child: Align(
        alignment: Alignment.centerRight,
        child: GestureDetector(
          onLongPress: () => _copyToClipboard(context, message.text),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.spacing16,
              vertical: AppSizes.spacing12,
            ),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppSizes.spacing20),
                topRight: Radius.circular(AppSizes.spacing20),
                bottomLeft: Radius.circular(AppSizes.spacing20),
                bottomRight: Radius.circular(AppSizes.spacing4),
              ),
            ),
            child: MixedLatexText(
              text: message.text,
              style: theme.textTheme.bodyLarge?.copyWith(
                height: 1.5,
                color: theme.colorScheme.onPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TutorReply extends StatelessWidget {
  const _TutorReply({required this.message, this.onRetry, this.onPickLesson});

  final AiTutorMessage message;
  final VoidCallback? onRetry;
  final VoidCallback? onPickLesson;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final Widget content;
    if (message.requiresLesson) {
      content = _PickLessonPrompt(onPickLesson: onPickLesson);
    } else if (message.isError) {
      content = _ErrorContent(errorKey: message.errorKey!, onRetry: onRetry);
    } else if (message.isStreaming && message.text.isEmpty) {
      content = const AiTutorTypingIndicator();
    } else {
      content = AiTutorRichText(
        text: message.text,
        showCursor: message.isStreaming,
        style: theme.textTheme.bodyLarge?.copyWith(
          height: 1.6,
          color: theme.colorScheme.onSurface,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.spacing12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 2),
            child: AiTutorAvatar(size: 28),
          ),
          const SizedBox(width: AppSizes.spacing12),
          Expanded(
            child: GestureDetector(
              onLongPress: message.isError || message.isStreaming || message.requiresLesson
                  ? null
                  : () => _copyToClipboard(context, message.text),
              child: content,
            ),
          ),
        ],
      ),
    );
  }
}

/// Tutor reply shown when the student asks before choosing a lesson.
class _PickLessonPrompt extends StatelessWidget {
  const _PickLessonPrompt({this.onPickLesson});

  final VoidCallback? onPickLesson;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSizes.spacing16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppSizes.spacing16),
        border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            context.l10n.text('aiTutorPickLessonFirst'),
            style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
          ),
          if (onPickLesson != null) ...[
            const SizedBox(height: AppSizes.spacing12),
            FilledButton.icon(
              onPressed: onPickLesson,
              icon: const Icon(Icons.menu_book_rounded, size: 18),
              label: Text(context.l10n.text('aiTutorPickLessonTitle')),
            ),
          ],
        ],
      ),
    );
  }
}

class _ErrorContent extends StatelessWidget {
  const _ErrorContent({required this.errorKey, this.onRetry});

  final String errorKey;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final canRetry = onRetry != null && errorKey != 'aiTutorLimitReached';

    return Container(
      padding: const EdgeInsets.all(AppSizes.spacing12),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppSizes.spacing12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.error_outline, size: 18, color: theme.colorScheme.error),
              const SizedBox(width: AppSizes.spacing8),
              Expanded(
                child: Text(
                  context.l10n.text(errorKey),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onErrorContainer,
                  ),
                ),
              ),
            ],
          ),
          if (canRetry)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh, size: 18),
                label: Text(context.l10n.text('aiTutorRetry')),
              ),
            ),
        ],
      ),
    );
  }
}

Future<void> _copyToClipboard(BuildContext context, String text) async {
  await Clipboard.setData(ClipboardData(text: text));
  if (!context.mounted) return;
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(context.l10n.text('aiTutorCopied')),
        duration: const Duration(seconds: 1),
      ),
    );
}
