import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../localization/app_localizations.dart';
import '../../../auth/application/grade_controller.dart';
import '../../../auth/domain/models/grade_model.dart';
import '../pages/learning_center_page.dart';

class GradeListBody extends ConsumerWidget {
  const GradeListBody({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gradesState = ref.watch(gradesProvider);
    final theme = Theme.of(context);
    final textTheme = GoogleFonts.battambangTextTheme(theme.textTheme);

    return Theme(
      data: theme.copyWith(textTheme: textTheme),
      child: gradesState.when(
        data: (grades) => _GradeListContent(
          grades: grades,
          onRefresh: () async {
            final _ = await ref.refresh(gradesProvider.future);
          },
        ),
        error: (_, _) =>
            _GradeListError(onRetry: () => ref.invalidate(gradesProvider)),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

class _GradeListContent extends StatelessWidget {
  const _GradeListContent({required this.grades, required this.onRefresh});

  final List<GradeModel> grades;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    if (grades.isEmpty) {
      return const _EmptyGrades();
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final columns = constraints.maxWidth >= 620 ? 2 : 1;

          return GridView.builder(
            padding: const EdgeInsets.fromLTRB(10, 24, 10, 112),
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: grades.length + 1,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              crossAxisSpacing: AppSizes.spacing16,
              mainAxisSpacing: AppSizes.spacing16,
              mainAxisExtent: 154,
            ),
            itemBuilder: (context, index) {
              if (index == 0) {
                return _GradeIntroduction(isWide: columns > 1);
              }
              final grade = grades[index - 1];
              return _GradeCard(grade: grade, index: index - 1);
            },
          );
        },
      ),
    );
  }
}

class _GradeIntroduction extends StatelessWidget {
  const _GradeIntroduction({required this.isWide});

  final bool isWide;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(AppSizes.spacing16),
      alignment: Alignment.centerLeft,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.text('chooseGrade'),
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.secondary,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: AppSizes.spacing8),
          Text(
            context.l10n.text('gradeListDescription'),
            maxLines: isWide ? 3 : 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class _GradeCard extends StatelessWidget {
  const _GradeCard({required this.grade, required this.index});

  final GradeModel grade;
  final int index;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isPrimary = index.isEven;
    final accent = isPrimary ? colors.primary : colors.secondary;
    final background = isPrimary
        ? colors.primaryContainer
        : colors.secondaryContainer;
    final foreground = isPrimary
        ? colors.onPrimaryContainer
        : colors.onSecondaryContainer;
    final label = '${context.l10n.text('gradePrefix')} ${grade.number}';

    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.goNamed(
          LearningCenterPage.routeName,
          queryParameters: {
            'gradeId': grade.id.toString(),
            'gradeNumber': grade.number.toString(),
          },
        ),
        child: Container(
          padding: const EdgeInsets.all(AppSizes.spacing16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: accent.withValues(alpha: 0.48),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: background,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.school_outlined, color: foreground, size: 32),
              ),
              const SizedBox(width: AppSizes.spacing16),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: colors.secondary,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: AppSizes.spacing4),
                    Text(
                      context.l10n.text('gradeCardDescription'),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: colors.secondary),
            ],
          ),
        ),
      ),
    );
  }
}

class _GradeListError extends StatelessWidget {
  const _GradeListError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(context.l10n.text('gradesLoadFailed')),
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

class _EmptyGrades extends StatelessWidget {
  const _EmptyGrades();

  @override
  Widget build(BuildContext context) {
    return Center(child: Text(context.l10n.text('gradeListEmpty')));
  }
}
