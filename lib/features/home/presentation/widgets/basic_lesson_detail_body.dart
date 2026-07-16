import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../localization/app_localizations.dart';
import '../../application/basic_course_controller.dart';
import '../pages/basic_lesson_list_page.dart';
import 'lesson_detail_body.dart';

class BasicLessonDetailBody extends ConsumerWidget {
  const BasicLessonDetailBody({
    required this.courseId,
    required this.lessonId,
    super.key,
  });

  final String courseId;
  final String lessonId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final languageCode = Localizations.localeOf(context).languageCode;
    final request = BasicLessonDetailRequest(
      courseId: courseId,
      lessonId: lessonId,
      languageCode: languageCode,
    );
    final detailState = ref.watch(basicLessonDetailProvider(request));
    final theme = Theme.of(context);
    final textTheme = GoogleFonts.battambangTextTheme(
      theme.textTheme,
    ).apply(fontSizeDelta: 3);

    return Theme(
      data: theme.copyWith(textTheme: textTheme),
      child: detailState.when(
        data: (detail) => LessonDetailContent(
          detail: detail,
          onBack: () => context.goNamed(
            BasicLessonListPage.routeName,
            pathParameters: {'courseId': courseId},
          ),
        ),
        error: (_, _) => _BasicLessonDetailError(
          onRetry: () => ref.invalidate(basicLessonDetailProvider(request)),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

class _BasicLessonDetailError extends StatelessWidget {
  const _BasicLessonDetailError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FilledButton.icon(
        onPressed: onRetry,
        icon: const Icon(Icons.refresh),
        label: Text(context.l10n.text('retry')),
      ),
    );
  }
}
