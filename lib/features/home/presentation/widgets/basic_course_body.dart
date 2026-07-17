import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../localization/app_localizations.dart';
import '../../application/basic_course_controller.dart';
import '../../domain/models/basic_course_model.dart';
import '../pages/basic_lesson_list_page.dart';

class BasicCourseBody extends ConsumerWidget {
  const BasicCourseBody({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final languageCode = Localizations.localeOf(context).languageCode;
    final coursesState = ref.watch(basicCoursesProvider(languageCode));
    final theme = Theme.of(context);
    final textTheme = GoogleFonts.battambangTextTheme(theme.textTheme);

    return Theme(
      data: theme.copyWith(textTheme: textTheme),
      child: coursesState.when(
        data: (courses) => _CourseContent(
          courses: courses,
          onRefresh: () async {
            final _ = await ref.refresh(
              basicCoursesProvider(languageCode).future,
            );
          },
        ),
        error: (_, _) => _CourseError(
          onRetry: () => ref.invalidate(basicCoursesProvider(languageCode)),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

class _CourseContent extends StatelessWidget {
  const _CourseContent({required this.courses, required this.onRefresh});

  final List<BasicCourseModel> courses;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    if (courses.isEmpty) {
      return const _EmptyCourses();
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final columns = constraints.maxWidth >= 720 ? 2 : 1;

          return GridView.builder(
            padding: const EdgeInsets.fromLTRB(10, 24, 10, 112),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              crossAxisSpacing: AppSizes.spacing16,
              mainAxisSpacing: AppSizes.spacing16,
              childAspectRatio: columns == 1 ? 1.28 : 1.18,
            ),
            itemCount: courses.length,
            itemBuilder: (context, index) =>
                _BasicCourseCard(course: courses[index], index: index),
          );
        },
      ),
    );
  }
}

class _BasicCourseCard extends StatelessWidget {
  const _BasicCourseCard({required this.course, required this.index});

  final BasicCourseModel course;
  final int index;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isPrimaryCard = index.isEven;
    final accent = isPrimaryCard ? colors.primary : colors.secondary;

    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(AppSizes.cardRadius),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.goNamed(
          BasicLessonListPage.routeName,
          pathParameters: {'courseId': course.id},
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSizes.cardRadius),
            border: Border.all(
              color: accent.withValues(alpha: 0.42),
              width: 1.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _CourseThumbnail(
                  course: course,
                  accent: accent,
                  isPrimaryCard: isPrimaryCard,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSizes.spacing16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: colors.secondary,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: AppSizes.spacing8),
                    Text(
                      course.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                        height: 1.5,
                      ),
                    ),
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

class _CourseThumbnail extends StatelessWidget {
  const _CourseThumbnail({
    required this.course,
    required this.accent,
    required this.isPrimaryCard,
  });

  final BasicCourseModel course;
  final Color accent;
  final bool isPrimaryCard;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.network(
          course.thumbnail,
          fit: BoxFit.cover,
          frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
            if (wasSynchronouslyLoaded || frame != null) return child;
            return _ThumbnailFallback(
              courseId: course.id,
              isPrimaryCard: isPrimaryCard,
            );
          },
          errorBuilder: (_, _, _) => _ThumbnailFallback(
            courseId: course.id,
            isPrimaryCard: isPrimaryCard,
          ),
        ),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, accent.withValues(alpha: 0.20)],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ThumbnailFallback extends StatelessWidget {
  const _ThumbnailFallback({
    required this.courseId,
    required this.isPrimaryCard,
  });

  final String courseId;
  final bool isPrimaryCard;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final background = isPrimaryCard
        ? colors.primaryContainer
        : colors.secondaryContainer;
    final foreground = isPrimaryCard
        ? colors.onPrimaryContainer
        : colors.onSecondaryContainer;

    return ColoredBox(
      color: background,
      child: Center(
        child: Icon(_iconForCourse(courseId), color: foreground, size: 64),
      ),
    );
  }

  IconData _iconForCourse(String id) {
    return switch (id) {
      'mathematics' => Icons.calculate_outlined,
      'physics' => Icons.science_outlined,
      'chemistry' => Icons.biotech_outlined,
      'biology' => Icons.eco_outlined,
      _ => Icons.menu_book_outlined,
    };
  }
}

class _CourseError extends StatelessWidget {
  const _CourseError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.spacing24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_off_outlined,
              size: 52,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: AppSizes.spacing16),
            Text(
              context.l10n.text('basicCourseLoadFailed'),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.spacing16),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: Text(context.l10n.text('retry')),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyCourses extends StatelessWidget {
  const _EmptyCourses();

  @override
  Widget build(BuildContext context) {
    return Center(child: Text(context.l10n.text('basicCourseEmpty')));
  }
}
