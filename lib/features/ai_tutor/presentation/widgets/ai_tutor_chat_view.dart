import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../application/ai_tutor_controller.dart';
import '../../domain/models/ai_tutor_chat_state.dart';
import 'ai_tutor_input_bar.dart';
import 'ai_tutor_lesson_context_bar.dart';
import 'ai_tutor_lesson_picker_sheet.dart';
import 'ai_tutor_message_bubble.dart';
import 'ai_tutor_welcome.dart';

/// Message list + lesson chip + input bar for one tutor session.
class AiTutorChatView extends ConsumerWidget {
  const AiTutorChatView({required this.session, super.key});

  final AiTutorSession session;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = aiTutorControllerProvider(session);
    final chat = ref.watch(provider);
    final controller = ref.read(provider.notifier);

    Future<void> pickLesson() async {
      final picked = await AiTutorLessonPickerSheet.show(
        context,
        selected: ref.read(provider).attachedLesson,
      );
      if (picked != null) controller.attachLesson(picked);
    }

    return Column(
      children: [
        Expanded(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 896),
              child: chat.isEmpty
                  ? AiTutorWelcome(
                      isLessonMode: chat.attachedLesson != null,
                      lessonTitle: chat.attachedLesson?.title,
                      onSuggestionTap: controller.send,
                      onPickLesson: pickLesson,
                    )
                  : _MessageList(
                      chat: chat,
                      onRetry: controller.retry,
                      onPickLesson: chat.isSending ? null : pickLesson,
                    ),
            ),
          ),
        ),
        AiTutorLessonContextBar(
          lesson: chat.attachedLesson,
          enabled: !chat.isSending,
          onPick: pickLesson,
          onDetach: controller.detachLesson,
        ),
        AiTutorInputBar(
          isSending: chat.isSending,
          onSend: controller.send,
          onStop: controller.stop,
        ),
      ],
    );
  }
}

class _MessageList extends StatelessWidget {
  const _MessageList({
    required this.chat,
    required this.onRetry,
    required this.onPickLesson,
  });

  final AiTutorChatState chat;
  final ValueChanged<String> onRetry;
  final VoidCallback? onPickLesson;

  @override
  Widget build(BuildContext context) {
    final messages = chat.messages;

    // reverse: true keeps the newest text pinned to the bottom while it is
    // being written, exactly like ChatGPT.
    return ListView.builder(
      reverse: true,
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.spacing16,
        vertical: AppSizes.spacing16,
      ),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[messages.length - 1 - index];
        return AiTutorMessageBubble(
          key: ValueKey(message.id),
          message: message,
          onRetry: message.isError ? () => onRetry(message.id) : null,
          // Only the latest prompt keeps its button active.
          onPickLesson: message.requiresLesson && index == 0 ? onPickLesson : null,
        );
      },
    );
  }
}
