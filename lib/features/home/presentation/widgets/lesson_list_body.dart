import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../localization/app_localizations.dart';
import '../../../../theme/app_colors.dart';
import '../../application/lesson_controller.dart';
import '../../application/tutorial_controller.dart';
import '../../domain/models/lesson_model.dart';
import '../pages/lesson_detail_page.dart';
import '../pages/learning_center_page.dart';
import 'lesson_list_skeleton.dart';

class LessonListBody extends ConsumerWidget {
  const LessonListBody({
    required this.courseId,
    this.gradeId,
    this.gradeNumber,
    this.subjectId,
    super.key,
  });

  final String courseId;
  final int? gradeId;
  final int? gradeNumber;
  final int? subjectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final battambangTheme = GoogleFonts.battambangTextTheme(
      theme.textTheme,
    ).apply(fontSizeDelta: 3);
    final lessonId = int.tryParse(courseId);
    final tutorialRequest =
        gradeId == null || subjectId == null || lessonId == null
        ? null
        : TutorialRequest(
            subjectId: subjectId!,
            gradeId: gradeId!,
            lessonId: lessonId,
          );
    final lessonsState = tutorialRequest == null
        ? ref.watch(lessonBundleProvider(courseId))
        : ref.watch(tutorialBundleProvider(tutorialRequest));

    return Theme(
      data: theme.copyWith(textTheme: battambangTheme),
      child: RefreshIndicator(
        edgeOffset: 56,
        displacement: 72,
        color: theme.colorScheme.primary,
        backgroundColor: theme.colorScheme.surface,
        onRefresh: () => _refreshLessons(ref, tutorialRequest: tutorialRequest),
        child: SafeArea(
          child: Column(
            children: [
              SizedBox(
                height: 56,
                child: _LessonHeader(
                  title: context.l10n.text('lessonsTitle'),
                  onBack: () => context.goNamed(
                    LearningCenterPage.routeName,
                    queryParameters: {
                      if (gradeId != null) 'gradeId': gradeId.toString(),
                      if (gradeNumber != null)
                        'gradeNumber': gradeNumber.toString(),
                      if (subjectId != null) 'subjectId': subjectId.toString(),
                    },
                  ),
                ),
              ),
              Expanded(
                child: lessonsState.when(
                  skipLoadingOnRefresh: false,
                  data: (bundle) => _LessonListContent(
                    bundle: bundle,
                    gradeId: gradeId,
                    gradeNumber: gradeNumber,
                    subjectId: subjectId,
                  ),
                  error: (_, _) => const _LessonListError(),
                  loading: () => const LessonListSkeleton(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _refreshLessons(
    WidgetRef ref, {
    required TutorialRequest? tutorialRequest,
  }) async {
    if (tutorialRequest != null) {
      final provider = tutorialBundleProvider(tutorialRequest);
      ref.invalidate(provider);
      await ref.read(provider.future);
      return;
    }
    final provider = lessonBundleProvider(courseId);
    ref.invalidate(provider);
    await ref.read(provider.future);
  }
}

class _LessonListContent extends StatelessWidget {
  const _LessonListContent({
    required this.bundle,
    this.gradeId,
    this.gradeNumber,
    this.subjectId,
  });

  final CourseLessonBundle bundle;
  final int? gradeId;
  final int? gradeNumber;
  final int? subjectId;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        10,
        AppSizes.spacing32,
        10,
        AppSizes.pageBottomPadding,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _LessonSummaryCard(bundle: bundle),
              const SizedBox(height: AppSizes.spacing32),
              Text(
                context.l10n.text('lessonsTitle'),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Theme.of(context).colorScheme.secondary,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: AppSizes.spacing16),
              for (final lesson in bundle.lessons) ...[
                _LessonTile(
                  lesson: lesson,
                  gradeId: gradeId,
                  gradeNumber: gradeNumber,
                  subjectId: subjectId,
                ),
                const SizedBox(height: AppSizes.spacing16),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _LessonHeader extends StatelessWidget {
  const _LessonHeader({required this.title, required this.onBack});

  final String title;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      color: theme.colorScheme.surface.withValues(alpha: 0.92),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.spacing16,
        vertical: AppSizes.spacing8,
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
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
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.bookmark_border),
            color: theme.colorScheme.secondary,
          ),
        ],
      ),
    );
  }
}

class _LessonSummaryCard extends StatelessWidget {
  const _LessonSummaryCard({required this.bundle});

  final CourseLessonBundle bundle;

  @override
  Widget build(BuildContext context) {
    const background = Color(0xFFE0F2FE);
    const foreground = AppColors.secondary;
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppSizes.featureCardRadius),
        border: Border.all(color: AppColors.primary, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            top: -40,
            right: -40,
            child: _BlurCircle(size: 128, opacity: 0.30),
          ),
          Positioned(
            left: -44,
            bottom: -46,
            child: _BlurCircle(size: 160, opacity: 0.20),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSizes.spacing24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.school, color: AppColors.secondary),
                ),
                const SizedBox(height: AppSizes.spacing24),
                Text(
                  context.l10n.text(bundle.titleKey),
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: foreground,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: AppSizes.spacing8),
                Text(
                  context.l10n.text(bundle.descriptionKey),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.secondary.withValues(alpha: 0.82),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LessonTile extends StatelessWidget {
  const _LessonTile({
    required this.lesson,
    this.gradeId,
    this.gradeNumber,
    this.subjectId,
  });

  final LessonModel lesson;
  final int? gradeId;
  final int? gradeNumber;
  final int? subjectId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLocked = lesson.type == LessonType.locked;

    return Material(
      color: isLocked
          ? theme.colorScheme.surfaceContainerLow
          : theme.colorScheme.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(AppSizes.cardRadius),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        onTap: isLocked
            ? null
            : () => context.goNamed(
                LessonDetailPage.routeName,
                pathParameters: {
                  'courseId': lesson.courseId,
                  'lessonId': lesson.id,
                },
                queryParameters: {
                  if (lesson.slug.isNotEmpty) 'slug': lesson.slug,
                  if (gradeId != null) 'gradeId': gradeId.toString(),
                  if (gradeNumber != null)
                    'gradeNumber': gradeNumber.toString(),
                  if (subjectId != null) 'subjectId': subjectId.toString(),
                },
              ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSizes.cardRadius),
            border: Border.all(
              color: isLocked
                  ? theme.colorScheme.outlineVariant.withValues(alpha: 0.35)
                  : theme.colorScheme.surfaceContainerHighest,
              width: 2,
            ),
            boxShadow: isLocked
                ? null
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          padding: const EdgeInsets.all(AppSizes.spacing16),
          child: Row(
            children: [
              _LessonIcon(lesson: lesson),
              const SizedBox(width: AppSizes.spacing16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lesson.title?.isNotEmpty == true
                          ? lesson.title!
                          : context.l10n.text(lesson.titleKey),
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (lesson.type != LessonType.video) ...[
                      const SizedBox(height: AppSizes.spacing4),
                      Text(
                        _lessonMeta(context, lesson),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (lesson.isCompleted) const _CompletedBadge(),
            ],
          ),
        ),
      ),
    );
  }

  String _lessonMeta(BuildContext context, LessonModel lesson) {
    final typeKey = switch (lesson.type) {
      LessonType.video => 'lessonTypeVideo',
      LessonType.reading => 'lessonTypeReading',
      LessonType.locked => 'lessonTypeLocked',
    };
    return context.l10n.text(typeKey);
  }
}

class _LessonIcon extends StatelessWidget {
  const _LessonIcon({required this.lesson});

  final LessonModel lesson;

  @override
  Widget build(BuildContext context) {
    final colors = switch (lesson.type) {
      LessonType.video => (
        Theme.of(context).colorScheme.primaryContainer,
        Theme.of(context).colorScheme.onPrimaryContainer,
      ),
      LessonType.reading => (
        Theme.of(context).colorScheme.secondaryContainer,
        Theme.of(context).colorScheme.onSecondaryContainer,
      ),
      LessonType.locked => (
        Theme.of(context).colorScheme.surfaceContainerHighest,
        Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    };

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(color: colors.$1, shape: BoxShape.circle),
      child: Icon(lesson.icon, color: colors.$2),
    );
  }
}

class _CompletedBadge extends StatelessWidget {
  const _CompletedBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: const BoxDecoration(
        color: Color(0xFFC0EDD0),
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.check, color: Color(0xFF002112), size: 18),
    );
  }
}

class _BlurCircle extends StatelessWidget {
  const _BlurCircle({required this.size, required this.opacity});

  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: opacity),
        shape: BoxShape.circle,
      ),
    );
  }
}

class _LessonListError extends StatelessWidget {
  const _LessonListError();

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(child: Text(context.l10n.text('authFailed'))),
        ),
      ],
    );
  }
}
