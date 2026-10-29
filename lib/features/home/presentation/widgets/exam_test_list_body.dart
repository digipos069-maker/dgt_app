import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/widgets/app_skeleton.dart';
import '../../../../localization/app_localizations.dart';
import '../../../../theme/app_colors.dart';
import '../../application/resource_controller.dart';
import '../../domain/models/exam_test_model.dart';
import '../pages/exam_test_detail_page.dart';

/// Body of [ExamTestListPage]: every exam test ("ប្រឡងតេស្ត") as a card,
/// loaded page by page from `GET /api/m/exam-tests`.
class ExamTestListBody extends ConsumerWidget {
  const ExamTestListBody({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final testsState = ref.watch(examTestsProvider);
    final theme = Theme.of(context);

    return Theme(
      data: theme.copyWith(
        textTheme: GoogleFonts.battambangTextTheme(theme.textTheme),
      ),
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(overscroll: false),
        child: RefreshIndicator(
          onRefresh: () async {
            final _ = await ref.refresh(examTestsProvider.future);
          },
          child: NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              final metrics = notification.metrics;
              if (metrics.axis == Axis.vertical &&
                  metrics.pixels >= metrics.maxScrollExtent - 300) {
                ref.read(examTestsProvider.notifier).loadMore();
              }
              return false;
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: ClampingScrollPhysics(),
              ),
              padding: const EdgeInsets.fromLTRB(
                10,
                AppSizes.spacing16,
                10,
                AppSizes.pageBottomPadding,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _ExamTestHeader(count: testsState.value?.total),
                      const SizedBox(height: AppSizes.spacing16),
                      testsState.when(
                        data: (page) => page.tests.isEmpty
                            ? const _ExamTestEmpty()
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  _ExamTestGrid(tests: page.tests),
                                  if (page.isFetchingMore)
                                    const Padding(
                                      padding: EdgeInsets.all(
                                        AppSizes.spacing16,
                                      ),
                                      child: Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    ),
                                ],
                              ),
                        error: (_, _) => _ExamTestError(
                          onRetry: () => ref.invalidate(examTestsProvider),
                        ),
                        loading: () => const _ExamTestSkeleton(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ExamTestHeader extends StatelessWidget {
  const _ExamTestHeader({this.count});

  final int? count;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.text('examTestDescription'),
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colors.onSurfaceVariant,
            height: 1.5,
          ),
        ),
        if (count != null && count! > 0) ...[
          const SizedBox(height: AppSizes.spacing8),
          Text(
            context.l10n.text('examTestCount').replaceAll('{count}', '$count'),
            style: theme.textTheme.labelLarge?.copyWith(
              color: colors.secondary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ],
    );
  }
}

class _ExamTestGrid extends StatelessWidget {
  const _ExamTestGrid({required this.tests});

  final List<ExamTestModel> tests;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 720 ? 2 : 1;
        const gap = AppSizes.spacing16;
        final itemWidth =
            (constraints.maxWidth - gap * (columns - 1)) / columns;

        // Wrap instead of GridView so each card can size to its content
        // (Khmer text + large font scales would overflow a fixed extent).
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final test in tests)
              SizedBox(width: itemWidth, child: ExamTestCard(test: test)),
          ],
        );
      },
    );
  }
}

class ExamTestCard extends StatelessWidget {
  const ExamTestCard({required this.test, super.key});

  final ExamTestModel test;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final l10n = context.l10n;
    final languageCode = Localizations.localeOf(context).languageCode;
    final subjectName = test.subjectName(languageCode);

    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(AppSizes.cardRadius),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _onTap(context),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSizes.cardRadius),
            border: Border.all(color: colors.outlineVariant, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Top: icon, title, tags, action ──────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 12, 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _TestIconTile(isLocked: test.isLocked),
                    const SizedBox(width: AppSizes.spacing12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            test.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: colors.secondary,
                              fontWeight: FontWeight.w900,
                              height: 1.35,
                            ),
                          ),
                          const SizedBox(height: AppSizes.spacing4),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: [
                              if (subjectName.isNotEmpty)
                                ExamTestTag(
                                  label: subjectName,
                                  color: colors.primary,
                                ),
                              if (test.grade != null && test.grade!.number > 0)
                                ExamTestTag(
                                  label: l10n
                                      .text('examTestGrade')
                                      .replaceAll(
                                        '{grade}',
                                        '${test.grade!.number}',
                                      ),
                                  color: AppColors.brandButton,
                                ),
                              if (test.track.isNotEmpty)
                                ExamTestTag(
                                  label: test.track,
                                  color: const Color(0xFFD97706),
                                ),
                              if (test.examTypeName.isNotEmpty)
                                ExamTestTag(
                                  label: test.examTypeName,
                                  color: colors.secondary,
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSizes.spacing8),
                    _StartButton(isLocked: test.isLocked),
                  ],
                ),
              ),

              // ── Middle: stats strip ─────────────────────────────────────
              ExamTestStatsStrip(
                questionCount: test.quizCount,
                durationMinutes: test.durationMinutes,
                totalScore: test.totalScore,
              ),

              // ── Bottom: passing score ───────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                child: Row(
                  children: [
                    Icon(
                      Icons.flag_outlined,
                      size: 16,
                      color: colors.onSurfaceVariant,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        l10n
                            .text('examTestPassingScore')
                            .replaceAll('{pass}', '${test.passingScore}')
                            .replaceAll('{total}', '${test.totalScore}'),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
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

  void _onTap(BuildContext context) {
    if (test.isLocked) {
      // TODO(exam-test): open the upgrade-subscription modal instead.
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(context.l10n.text('examTestLockedMessage'))),
        );
      return;
    }
    context.push(ExamTestDetailPage.pathFor(test.id));
  }
}

/// Questions · minutes · points row, shared by the list card and the
/// detail page intro.
class ExamTestStatsStrip extends StatelessWidget {
  const ExamTestStatsStrip({
    required this.questionCount,
    required this.durationMinutes,
    required this.totalScore,
    this.margin = const EdgeInsets.symmetric(horizontal: 12),
    super.key,
  });

  final int questionCount;
  final int durationMinutes;
  final int totalScore;
  final EdgeInsetsGeometry margin;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final l10n = context.l10n;

    return Container(
      margin: margin,
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          _Stat(
            icon: Icons.help_outline_rounded,
            value: '$questionCount',
            label: l10n.text('examTestQuestions'),
          ),
          _StatDivider(color: colors.outlineVariant),
          _Stat(
            icon: Icons.timer_outlined,
            value: '$durationMinutes',
            label: l10n.text('examTestMinutes'),
          ),
          _StatDivider(color: colors.outlineVariant),
          _Stat(
            icon: Icons.star_outline_rounded,
            value: '$totalScore',
            label: l10n.text('examTestScore'),
          ),
        ],
      ),
    );
  }
}

class ExamTestTag extends StatelessWidget {
  const ExamTestTag({required this.label, required this.color, super.key});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _TestIconTile extends StatelessWidget {
  const _TestIconTile({required this.isLocked});

  final bool isLocked;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isLocked
              ? [colors.surfaceContainerHighest, colors.outlineVariant]
              : const [AppColors.primary, AppColors.brandButton],
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(
        Icons.assignment_outlined,
        color: isLocked ? colors.onSurfaceVariant : Colors.white,
        size: 26,
      ),
    );
  }
}

class _StartButton extends StatelessWidget {
  const _StartButton({required this.isLocked});

  final bool isLocked;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: isLocked ? colors.surfaceContainerHighest : colors.secondary,
        shape: BoxShape.circle,
      ),
      child: Icon(
        isLocked ? Icons.lock_outline_rounded : Icons.play_arrow_rounded,
        size: 20,
        color: isLocked ? colors.onSurfaceVariant : colors.onSecondary,
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.icon, required this.value, required this.label});

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: colors.primary),
              const SizedBox(width: 4),
              Text(
                value,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelSmall?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatDivider extends StatelessWidget {
  const _StatDivider({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 28, color: color);
  }
}

class _ExamTestSkeleton extends StatelessWidget {
  const _ExamTestSkeleton();

  @override
  Widget build(BuildContext context) {
    return AppSkeletonShimmer(
      child: Column(
        children: List.generate(
          3,
          (index) => Padding(
            padding: EdgeInsets.only(top: index == 0 ? 0 : AppSizes.spacing16),
            child: const AppSkeletonBox(
              height: 176,
              borderRadius: AppSizes.cardRadius,
            ),
          ),
        ),
      ),
    );
  }
}

class _ExamTestError extends StatelessWidget {
  const _ExamTestError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppSizes.spacing16),
      decoration: BoxDecoration(
        color: colors.errorContainer.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
      ),
      child: Row(
        children: [
          Icon(Icons.cloud_off_outlined, color: colors.error),
          const SizedBox(width: AppSizes.spacing12),
          Expanded(child: Text(context.l10n.text('examTestLoadFailed'))),
          TextButton(
            onPressed: onRetry,
            child: Text(context.l10n.text('retry')),
          ),
        ],
      ),
    );
  }
}

class _ExamTestEmpty extends StatelessWidget {
  const _ExamTestEmpty();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        children: [
          Icon(
            Icons.assignment_outlined,
            size: 40,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: AppSizes.spacing8),
          Text(
            context.l10n.text('examTestEmpty'),
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
