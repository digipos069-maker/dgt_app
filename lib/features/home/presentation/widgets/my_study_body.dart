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
import '../pages/exam_test_list_page.dart';
import 'exam_test_list_body.dart' show ExamTestTag;

/// Lists results from `GET /api/m/exam-test-attempts`, newest first,
/// with a summary card on top.
class MyStudyBody extends ConsumerWidget {
  const MyStudyBody({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(myExamTestAttemptsProvider);
    final theme = Theme.of(context);

    return Theme(
      data: theme.copyWith(
        textTheme: GoogleFonts.battambangTextTheme(theme.textTheme),
      ),
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(overscroll: false),
        child: RefreshIndicator(
          onRefresh: () async {
            try {
              final _ = await ref.refresh(myExamTestAttemptsProvider.future);
            } catch (_) {}
          },
          child: NotificationListener<ScrollNotification>(
            onNotification: (n) {
              if (n.metrics.axis == Axis.vertical &&
                  n.metrics.pixels >= n.metrics.maxScrollExtent - 300) {
                ref.read(myExamTestAttemptsProvider.notifier).loadMore();
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
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: state.when(
                    data: (page) => page.attempts.isEmpty
                        ? const _EmptyResults()
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _SummaryCard(summary: page.summary),
                              const SizedBox(height: AppSizes.spacing24),
                              Text(
                                context.l10n.text('myStudyResultsTitle'),
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: theme.colorScheme.secondary,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: AppSizes.spacing12),
                              for (final (i, attempt)
                                  in page.attempts.indexed) ...[
                                if (i > 0)
                                  const SizedBox(height: AppSizes.spacing12),
                                _AttemptCard(attempt: attempt),
                              ],
                              if (page.isFetchingMore)
                                const Padding(
                                  padding: EdgeInsets.all(AppSizes.spacing16),
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                ),
                            ],
                          ),
                    error: (error, _) => _ErrorView(
                      notLoggedIn: error is NotLoggedInException,
                      onRetry: () => ref.invalidate(myExamTestAttemptsProvider),
                    ),
                    loading: () => const _LoadingView(),
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

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.summary});

  final ExamTestAttemptSummary summary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final l10n = context.l10n;

    return Container(
      padding: const EdgeInsets.all(AppSizes.spacing16),
      decoration: BoxDecoration(
        color: colors.primary,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.insights_rounded, color: colors.onPrimary),
              const SizedBox(width: AppSizes.spacing8),
              Expanded(
                child: Text(
                  l10n.text('myStudySummaryTitle'),
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: colors.onPrimary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.spacing16),
          Row(
            children: [
              _SummaryStat(
                value: '${summary.totalAttempts}',
                label: l10n.text('myStudyAttempts'),
              ),
              _SummaryStat(
                value: '${summary.passedCount}',
                label: l10n.text('myStudyPassed'),
              ),
              _SummaryStat(
                value: '${_formatPercent(summary.averageScorePercent)}%',
                label: l10n.text('myStudyAverage'),
              ),
              _SummaryStat(
                value: '${_formatPercent(summary.bestScorePercent)}%',
                label: l10n.text('myStudyBest'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryStat extends StatelessWidget {
  const _SummaryStat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onPrimary = theme.colorScheme.onPrimary;

    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              color: onPrimary,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelSmall?.copyWith(
              color: onPrimary.withValues(alpha: 0.85),
            ),
          ),
        ],
      ),
    );
  }
}

class _AttemptCard extends StatelessWidget {
  const _AttemptCard({required this.attempt});

  final ExamTestAttemptModel attempt;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final l10n = context.l10n;
    final languageCode = Localizations.localeOf(context).languageCode;
    final subjectName = attempt.subject?.localizedName(languageCode) ?? '';
    final accent = attempt.passed ? AppColors.success : AppColors.error;
    final ratio = (attempt.scorePercent / 100).clamp(0.0, 1.0);

    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(AppSizes.cardRadius),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        // Opens the test again so the student can retake it.
        onTap: attempt.examTestId > 0
            ? () => context.push(
                ExamTestDetailPage.pathFor('${attempt.examTestId}'),
              )
            : null,
        child: Container(
          padding: const EdgeInsets.all(AppSizes.spacing16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSizes.cardRadius),
            border: Border.all(
              color: colors.primary.withValues(alpha: 0.48),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              // Score ring
              SizedBox(
                width: 64,
                height: 64,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CircularProgressIndicator(
                      value: ratio,
                      strokeWidth: 6,
                      color: colors.primary,
                      backgroundColor: colors.surfaceContainerHighest,
                    ),
                    Center(
                      child: Text(
                        '${_formatPercent(attempt.scorePercent)}%',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: colors.secondary,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSizes.spacing16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            attempt.title.isNotEmpty
                                ? attempt.title
                                : l10n.text('examTestTitle'),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: colors.secondary,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSizes.spacing8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: accent.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            l10n.text(
                              attempt.passed
                                  ? 'examTestPassed'
                                  : 'examTestFailed',
                            ),
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: accent,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        if (subjectName.isNotEmpty)
                          ExamTestTag(
                            label: subjectName,
                            color: colors.secondary,
                          ),
                        if (attempt.grade != null && attempt.grade!.number > 0)
                          ExamTestTag(
                            label: l10n
                                .text('examTestGrade')
                                .replaceAll(
                                  '{grade}',
                                  '${attempt.grade!.number}',
                                ),
                            color: colors.secondary,
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: AppSizes.spacing12,
                      runSpacing: 4,
                      children: [
                        _Meta(
                          icon: Icons.star_outline_rounded,
                          text:
                              '${_formatPercent(attempt.score)}/${attempt.totalScore}',
                        ),
                        _Meta(
                          icon: Icons.check_circle_outline,
                          text:
                              '${attempt.correctCount}/${attempt.questionCount}',
                        ),
                        if (attempt.durationSeconds != null)
                          _Meta(
                            icon: Icons.timer_outlined,
                            text: _formatDuration(attempt.durationSeconds!),
                          ),
                        if (attempt.submittedAt != null)
                          _Meta(
                            icon: Icons.event_outlined,
                            text: _formatDate(attempt.submittedAt!),
                          ),
                      ],
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

class _Meta extends StatelessWidget {
  const _Meta({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme.onSurfaceVariant;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(text, style: theme.textTheme.bodySmall?.copyWith(color: color)),
      ],
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return AppSkeletonShimmer(
      child: Column(
        children: [
          const AppSkeletonBox(height: 120, borderRadius: AppSizes.cardRadius),
          for (var i = 0; i < 3; i++) ...[
            const SizedBox(height: AppSizes.spacing12),
            const AppSkeletonBox(height: 110, borderRadius: AppSizes.cardRadius),
          ],
        ],
      ),
    );
  }
}

class _EmptyResults extends StatelessWidget {
  const _EmptyResults();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(top: 48),
      child: Column(
        children: [
          Icon(Icons.assignment_outlined, size: 56, color: colors.primary),
          const SizedBox(height: AppSizes.spacing12),
          Text(
            context.l10n.text('myStudyEmpty'),
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSizes.spacing16),
          FilledButton.icon(
            style: FilledButton.styleFrom(foregroundColor: Colors.white),
            onPressed: () => context.push(ExamTestListPage.routePath),
            icon: const Icon(Icons.play_arrow_rounded),
            label: Text(context.l10n.text('myStudyTakeTest')),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.notLoggedIn, required this.onRetry});

  final bool notLoggedIn;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 48),
      child: Column(
        children: [
          Icon(
            notLoggedIn ? Icons.lock_outline : Icons.cloud_off_outlined,
            size: 52,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: AppSizes.spacing16),
          Text(
            context.l10n.text(
              notLoggedIn ? 'myStudyLoginRequired' : 'myStudyLoadFailed',
            ),
            textAlign: TextAlign.center,
          ),
          if (!notLoggedIn) ...[
            const SizedBox(height: AppSizes.spacing16),
            FilledButton.icon(
              style: FilledButton.styleFrom(foregroundColor: Colors.white),
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: Text(context.l10n.text('retry')),
            ),
          ],
        ],
      ),
    );
  }
}

String _formatPercent(double value) => value == value.roundToDouble()
    ? value.toInt().toString()
    : value.toStringAsFixed(1);

String _formatDuration(int totalSeconds) {
  final m = totalSeconds ~/ 60;
  final s = totalSeconds % 60;
  return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
}

String _formatDate(DateTime d) {
  String two(int v) => v.toString().padLeft(2, '0');
  return '${two(d.day)}/${two(d.month)}/${d.year} ${two(d.hour)}:${two(d.minute)}';
}
