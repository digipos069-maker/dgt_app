import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../localization/app_localizations.dart';
import '../../../ai_tutor/application/ai_tutor_controller.dart';
import '../../../ai_tutor/domain/models/ai_tutor_chat_state.dart';
import '../../../ai_tutor/presentation/widgets/ai_tutor_chat_view.dart';
import '../../../auth/presentation/pages/home_page.dart';
import '../widgets/main_bottom_navigation.dart';

/// AI tutor chat.
///
/// - Opened from a lesson (`?tutorialId=..&title=..`): answers are grounded in that lesson.
/// - Opened from the bottom navigation (no params): general study help.
class AiTutorPage extends ConsumerWidget {
  const AiTutorPage({this.tutorialId, this.lessonTitle, super.key});

  static const routeName = 'ai-tutor';
  static const routePath = '/ai-tutor';

  final int? tutorialId;
  final String? lessonTitle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final session = AiTutorSession(tutorialId: tutorialId, lessonTitle: lessonTitle);
    final provider = aiTutorControllerProvider(session);
    final hasMessages = ref.watch(provider.select((chat) => !chat.isEmpty));
    final isSending = ref.watch(provider.select((chat) => chat.isSending));
    final attachedTitle = ref.watch(provider.select((chat) => chat.attachedLesson?.title));
    // Opened from a lesson page: show a back button and hide the bottom nav.
    final openedFromLesson = tutorialId != null;

    return Scaffold(
      backgroundColor: theme.colorScheme.surfaceContainerLowest,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: openedFromLesson
            ? BackButton(onPressed: () => _goBack(context))
            : null,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(context.l10n.text('menuAiTutor')),
            Text(
              (attachedTitle?.isNotEmpty ?? false)
                  ? attachedTitle!
                  : context.l10n.text('aiTutorGeneralMode'),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        actions: [
          if (hasMessages)
            IconButton(
              tooltip: context.l10n.text('aiTutorNewChat'),
              icon: const Icon(Icons.add_comment_outlined),
              onPressed: isSending ? null : ref.read(provider.notifier).clear,
            ),
        ],
      ),
      body: AiTutorChatView(session: session),
      bottomNavigationBar: openedFromLesson
          ? null
          : const MainBottomNavigation(selectedIndex: 3),
    );
  }

  void _goBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.goNamed(HomePage.routeName);
    }
  }
}
