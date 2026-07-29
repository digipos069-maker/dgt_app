import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../localization/app_localizations.dart';
import '../../application/basic_course_controller.dart';
import '../../domain/models/basic_lesson_model.dart';
import '../pages/basic_course_page.dart';
import '../pages/basic_lesson_detail_page.dart';

class BasicLessonListBody extends ConsumerWidget {
  const BasicLessonListBody({required this.courseId, super.key});

  final String courseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final languageCode = Localizations.localeOf(context).languageCode;
    final request = BasicLessonsRequest(
      courseId: courseId,
      languageCode: languageCode,
    );
    final lessonsState = ref.watch(basicLessonsProvider(request));
    final theme = Theme.of(context);
    final textTheme = GoogleFonts.battambangTextTheme(
      theme.textTheme,
    ).apply(fontSizeDelta: 3);

    return Theme(
      data: theme.copyWith(textTheme: textTheme),
      child: lessonsState.when(
        data: (bundle) => _BasicLessonListContent(bundle: bundle),
        error: (_, _) => _BasicLessonListError(
          onRetry: () => ref.invalidate(basicLessonsProvider(request)),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

class _BasicLessonListContent extends StatelessWidget {
  const _BasicLessonListContent({required this.bundle});

  final BasicLessonBundle bundle;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          SizedBox(
            height: 56,
            child: _BasicLessonHeader(title: bundle.course.name),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(
                10,
                24,
                10,
                AppSizes.pageBottomPadding,
              ),
              itemCount: bundle.lessons.length + 1,
              separatorBuilder: (_, _) =>
                  const SizedBox(height: AppSizes.spacing16),
              itemBuilder: (context, index) {
                final Widget item;
                if (index == 0) {
                  item = _CourseIntroduction(bundle: bundle);
                } else {
                  item = _BasicLessonTile(lesson: bundle.lessons[index - 1]);
                }
                return Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 760),
                    child: item,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _BasicLessonHeader extends StatelessWidget {
  const _BasicLessonHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ColoredBox(
      color: theme.colorScheme.surface.withValues(alpha: 0.94),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          children: [
            IconButton(
              onPressed: () => context.goNamed(BasicCoursePage.routeName),
              icon: const Icon(Icons.arrow_back),
              color: theme.colorScheme.secondary,
            ),
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.secondary,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(width: 48),
          ],
        ),
      ),
    );
  }
}

class _CourseIntroduction extends StatelessWidget {
  const _CourseIntroduction({required this.bundle});

  final BasicLessonBundle bundle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.spacing8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.text('basicLessonsTitle'),
            style: theme.textTheme.headlineSmall?.copyWith(
              color: theme.colorScheme.secondary,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: AppSizes.spacing8),
          Text(
            bundle.course.description,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _BasicLessonTile extends StatelessWidget {
  const _BasicLessonTile({required this.lesson});

  final BasicLessonModel lesson;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.goNamed(
          BasicLessonDetailPage.routeName,
          pathParameters: {'courseId': lesson.courseId, 'lessonId': lesson.id},
        ),
        child: Container(
          height: 156,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.colorScheme.secondary.withValues(alpha: 0.24),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 116,
                height: 156,
                child: _LessonThumbnail(lesson: lesson),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(AppSizes.spacing16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        lesson.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.secondary,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: AppSizes.spacing4),
                      Text(
                        lesson.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: AppSizes.spacing8),
                      Row(
                        children: [
                          Icon(
                            Icons.schedule_outlined,
                            size: 17,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: AppSizes.spacing4),
                          Text(
                            lesson.durationLabel,
                            style: theme.textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Icon(Icons.chevron_right, color: theme.colorScheme.secondary),
              const SizedBox(width: AppSizes.spacing8),
            ],
          ),
        ),
      ),
    );
  }
}

class _LessonThumbnail extends StatelessWidget {
  const _LessonThumbnail({required this.lesson});

  final BasicLessonModel lesson;

  @override
  Widget build(BuildContext context) {
    return Image.network(
      lesson.thumbnail,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => ColoredBox(
        color: Theme.of(context).colorScheme.primaryContainer,
        child: Icon(
          Icons.menu_book_outlined,
          size: 42,
          color: Theme.of(context).colorScheme.onPrimaryContainer,
        ),
      ),
    );
  }
}

class _BasicLessonListError extends StatelessWidget {
  const _BasicLessonListError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(context.l10n.text('basicLessonLoadFailed')),
          const SizedBox(height: AppSizes.spacing16),
          FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: Text(context.l10n.text('retry')),
          ),
        ],
      ),
    );
  }
}
