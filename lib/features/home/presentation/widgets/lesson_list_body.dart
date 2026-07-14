import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../localization/app_localizations.dart';
import '../../application/lesson_controller.dart';
import '../../domain/models/lesson_model.dart';
import '../pages/lesson_detail_page.dart';
import '../pages/learning_center_page.dart';

class LessonListBody extends ConsumerWidget {
  const LessonListBody({required this.courseId, super.key});

  final String courseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final battambangTheme = GoogleFonts.battambangTextTheme(theme.textTheme);
    final lessonsState = ref.watch(lessonBundleProvider(courseId));

    return Theme(
      data: theme.copyWith(textTheme: battambangTheme),
      child: lessonsState.when(
        data: (bundle) => _LessonListContent(bundle: bundle),
        error: (_, _) => const _LessonListError(),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

class _LessonListContent extends StatelessWidget {
  const _LessonListContent({required this.bundle});

  final CourseLessonBundle bundle;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          _LessonHeader(title: context.l10n.text(bundle.appBarTitleKey)),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                AppSizes.spacing24,
                AppSizes.spacing32,
                AppSizes.spacing24,
                112,
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
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: AppSizes.spacing16),
                      for (final lesson in bundle.lessons) ...[
                        _LessonTile(lesson: lesson),
                        const SizedBox(height: AppSizes.spacing16),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LessonHeader extends StatelessWidget {
  const _LessonHeader({required this.title});

  final String title;

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
            onPressed: () => context.goNamed(LearningCenterPage.routeName),
            icon: const Icon(Icons.arrow_back),
            color: theme.colorScheme.primary,
          ),
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.bookmark_border),
            color: theme.colorScheme.primary,
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
    const background = Color(0xFFC0EDD0);
    const foreground = Color(0xFF002112);
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: const Color(0xFFA4D1B4), width: 2),
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
                  child: const Icon(Icons.school, color: Color(0xFF0F3925)),
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
                    color: const Color(0xFF264F39),
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
  const _LessonTile({required this.lesson});

  final LessonModel lesson;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLocked = lesson.type == LessonType.locked;

    return Material(
      color: isLocked
          ? theme.colorScheme.surfaceContainerLow
          : theme.colorScheme.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: isLocked
            ? null
            : () => context.goNamed(
                LessonDetailPage.routeName,
                pathParameters: {
                  'courseId': lesson.courseId,
                  'lessonId': lesson.id,
                },
              ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
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
                      context.l10n.text(lesson.titleKey),
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppSizes.spacing4),
                    Text(
                      _lessonMeta(context, lesson),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
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
    if (lesson.type == LessonType.locked) {
      return context.l10n.text(typeKey);
    }
    return '${context.l10n.text(typeKey)} • ${lesson.durationMinutes} ${context.l10n.text('minutesShort')}';
  }
}

class _LessonIcon extends StatelessWidget {
  const _LessonIcon({required this.lesson});

  final LessonModel lesson;

  @override
  Widget build(BuildContext context) {
    final colors = switch (lesson.type) {
      LessonType.video => (const Color(0xFFAB8FFE), const Color(0xFF3F1E8C)),
      LessonType.reading => (const Color(0xFFE8DDFF), const Color(0xFF21005E)),
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
    return Center(child: Text(context.l10n.text('authFailed')));
  }
}
