import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../localization/app_localizations.dart';
import '../../../../theme/app_colors.dart';
import '../../application/learning_lesson_controller.dart';
import '../../domain/models/learning_lesson_model.dart';
import '../pages/lesson_list_page.dart';

class LearningCenterBody extends ConsumerStatefulWidget {
  const LearningCenterBody({
    this.gradeId,
    this.gradeNumber,
    this.initialSubjectId = 1,
    this.onBack,
    super.key,
  });

  final int? gradeId;
  final int? gradeNumber;
  final int initialSubjectId;
  final VoidCallback? onBack;

  @override
  ConsumerState<LearningCenterBody> createState() => _LearningCenterBodyState();
}

class _LearningCenterBodyState extends ConsumerState<LearningCenterBody> {
  late int _selectedSubjectId;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _selectedSubjectId = widget.initialSubjectId.clamp(1, 4);
  }

  @override
  Widget build(BuildContext context) {
    const horizontalPadding = 10.0;
    final theme = Theme.of(context);
    final battambangTheme = GoogleFonts.battambangTextTheme(theme.textTheme);
    final request = widget.gradeId == null
        ? null
        : LearningLessonsRequest(
            gradeId: widget.gradeId!,
            subjectId: _selectedSubjectId,
          );
    final lessonsState = request == null
        ? null
        : ref.watch(learningLessonsProvider(request));

    return Theme(
      data: theme.copyWith(textTheme: battambangTheme),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            horizontalPadding,
            32,
            horizontalPadding,
            112,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1280),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _LearningHeader(
                    onBack: widget.onBack,
                    onSearchChanged: (value) {
                      setState(() => _searchQuery = value.trim().toLowerCase());
                    },
                  ),
                  if (widget.gradeNumber != null) ...[
                    const SizedBox(height: AppSizes.spacing24),
                    _SelectedGradeBadge(gradeNumber: widget.gradeNumber!),
                  ],
                  const SizedBox(height: AppSizes.spacing24),
                  _SubjectCategoryStrip(
                    selectedSubjectId: _selectedSubjectId,
                    onSelected: (subjectId) {
                      if (_selectedSubjectId == subjectId) return;
                      setState(() => _selectedSubjectId = subjectId);
                    },
                  ),
                  const SizedBox(height: AppSizes.spacing24),
                  if (request == null || lessonsState == null)
                    const _SelectGradeMessage()
                  else
                    _LessonResults(
                      lessonsState: lessonsState,
                      gradeId: widget.gradeId!,
                      gradeNumber: widget.gradeNumber,
                      subjectId: _selectedSubjectId,
                      searchQuery: _searchQuery,
                      onRetry: () =>
                          ref.invalidate(learningLessonsProvider(request)),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SelectedGradeBadge extends StatelessWidget {
  const _SelectedGradeBadge({required this.gradeNumber});

  final int gradeNumber;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: colors.primaryContainer,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colors.primary, width: 1.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.school_outlined, color: colors.secondary, size: 20),
            const SizedBox(width: AppSizes.spacing8),
            Text(
              '${context.l10n.text('gradePrefix')} $gradeNumber',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: colors.secondary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LearningHeader extends StatelessWidget {
  const _LearningHeader({this.onBack, required this.onSearchChanged});

  final VoidCallback? onBack;
  final ValueChanged<String> onSearchChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isWide = MediaQuery.sizeOf(context).width >= 720;

    final search = ConstrainedBox(
      constraints: BoxConstraints(maxWidth: isWide ? 380 : double.infinity),
      child: TextField(
        onChanged: onSearchChanged,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: context.l10n.text('learningCenterSearchHint'),
          prefixIcon: const Icon(Icons.search),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSizes.spacing16,
            vertical: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(999),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(999),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(999),
            borderSide: BorderSide(
              color: theme.colorScheme.secondary.withValues(alpha: 0.5),
              width: 2,
            ),
          ),
        ),
      ),
    );

    final backButton = IconButton.outlined(
      onPressed: onBack,
      tooltip: MaterialLocalizations.of(context).backButtonTooltip,
      icon: const Icon(Icons.arrow_back),
      color: theme.colorScheme.secondary,
      style: IconButton.styleFrom(
        minimumSize: const Size(48, 48),
        side: BorderSide(
          color: theme.colorScheme.primary.withValues(alpha: 0.72),
          width: 1.5,
        ),
      ),
    );

    if (!isWide) {
      return Row(
        children: [
          if (onBack != null) ...[
            backButton,
            const SizedBox(width: AppSizes.spacing8),
          ],
          Expanded(child: search),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [if (onBack != null) backButton, const Spacer(), search],
    );
  }
}

class _SubjectCategoryStrip extends StatelessWidget {
  const _SubjectCategoryStrip({
    required this.selectedSubjectId,
    required this.onSelected,
  });

  final int selectedSubjectId;
  final ValueChanged<int> onSelected;

  static const _subjects = [
    _SubjectCategoryData(
      id: 1,
      labelKey: 'subjectMath',
      icon: Icons.calculate,
      background: Color(0xFFE0F2FE),
      foreground: AppColors.secondary,
      border: Color(0xFF7DD3FC),
    ),
    _SubjectCategoryData(
      id: 2,
      labelKey: 'subjectPhysics',
      icon: Icons.science,
      background: Color(0xFFE8EDFA),
      foreground: AppColors.secondary,
      border: Color(0xFFB8C5E5),
    ),
    _SubjectCategoryData(
      id: 3,
      labelKey: 'subjectChemistry',
      icon: Icons.biotech,
      background: Color(0xFFE0F2FE),
      foreground: AppColors.secondary,
      border: Color(0xFF7DD3FC),
    ),
    _SubjectCategoryData(
      id: 4,
      labelKey: 'subjectBiology',
      icon: Icons.eco,
      background: Color(0xFFE8EDFA),
      foreground: AppColors.secondary,
      border: Color(0xFFB8C5E5),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final subject in _subjects) ...[
            _SubjectCategoryCard(
              subject: subject,
              isSelected: subject.id == selectedSubjectId,
              onTap: () => onSelected(subject.id),
            ),
            const SizedBox(width: AppSizes.spacing16),
          ],
        ],
      ),
    );
  }
}

class _SubjectCategoryCard extends StatelessWidget {
  const _SubjectCategoryCard({
    required this.subject,
    required this.isSelected,
    required this.onTap,
  });

  final _SubjectCategoryData subject;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected
          ? Theme.of(context).colorScheme.primaryContainer
          : subject.background,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Container(
          width: 112,
          padding: const EdgeInsets.all(AppSizes.spacing16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isSelected ? AppColors.primary : subject.border,
              width: isSelected ? 2.5 : 2,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(subject.icon, color: subject.foreground, size: 28),
              const SizedBox(height: AppSizes.spacing8),
              Text(
                context.l10n.text(subject.labelKey),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: subject.foreground,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LessonResults extends StatelessWidget {
  const _LessonResults({
    required this.lessonsState,
    required this.gradeId,
    required this.gradeNumber,
    required this.subjectId,
    required this.searchQuery,
    required this.onRetry,
  });

  final AsyncValue<List<LearningLessonModel>> lessonsState;
  final int gradeId;
  final int? gradeNumber;
  final int subjectId;
  final String searchQuery;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return lessonsState.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 48),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (_, _) => _LessonsError(onRetry: onRetry),
      data: (lessons) {
        if (lessons.isEmpty) return const _EmptyLessons();
        return _buildFilteredLessonCards(lessons);
      },
    );
  }

  Widget _buildFilteredLessonCards(List<LearningLessonModel> lessons) {
    final filtered = searchQuery.isEmpty
        ? lessons
        : lessons
              .where(
                (lesson) =>
                    lesson.title.toLowerCase().contains(searchQuery) ||
                    lesson.description.toLowerCase().contains(searchQuery),
              )
              .toList(growable: false);

    if (filtered.isEmpty) return const _EmptyLessons();

    return Column(
      children: [
        for (final lesson in filtered) ...[
          _LessonCard(
            lesson: lesson,
            gradeId: gradeId,
            gradeNumber: gradeNumber,
            subjectId: subjectId,
          ),
          const SizedBox(height: AppSizes.spacing24),
        ],
      ],
    );
  }
}

class _LessonCard extends StatelessWidget {
  const _LessonCard({
    required this.lesson,
    required this.gradeId,
    required this.gradeNumber,
    required this.subjectId,
  });

  final LearningLessonModel lesson;
  final int gradeId;
  final int? gradeNumber;
  final int subjectId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final background = subjectId.isOdd
        ? const Color(0xFFE0F2FE)
        : const Color(0xFFE8EDFA);
    final accent = subjectId.isOdd ? AppColors.primary : AppColors.secondary;
    final title = lesson.title.isEmpty
        ? '${context.l10n.text(_subjectLabelKey(subjectId))} - ${context.l10n.text('lessonsTitle')}'
        : lesson.title;
    final description = lesson.description.isEmpty
        ? context.l10n.text('gradeCardDescription')
        : lesson.description;
    final courseId = lesson.id.isEmpty
        ? _fallbackCourseId(subjectId)
        : lesson.id;

    return Material(
      color: background,
      borderRadius: BorderRadius.circular(32),
      child: InkWell(
        borderRadius: BorderRadius.circular(32),
        onTap: lesson.isLocked
            ? null
            : () => context.goNamed(
                LessonListPage.routeName,
                pathParameters: {'courseId': courseId},
                queryParameters: {
                  'gradeId': gradeId.toString(),
                  if (gradeNumber != null)
                    'gradeNumber': gradeNumber.toString(),
                  'subjectId': subjectId.toString(),
                },
              ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: accent.withValues(alpha: 0.48), width: 2),
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
                top: 28,
                right: 28,
                child: Icon(
                  Icons.auto_awesome,
                  size: 62,
                  color: Colors.white.withValues(alpha: 0.55),
                ),
              ),
              Positioned(
                right: -34,
                bottom: -38,
                child: Icon(
                  Icons.menu_book,
                  size: 128,
                  color: Colors.black.withValues(alpha: 0.07),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSizes.spacing24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _LessonIcon(subjectId: subjectId),
                        const Spacer(),
                        _RatingBadge(
                          rating: lesson.rating > 0 ? lesson.rating : 4.8,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSizes.spacing20),
                    Text(
                      context.l10n.text(_subjectLabelKey(subjectId)),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.secondary.withValues(alpha: 0.72),
                        fontSize: 14,
                        height: 1.42,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: AppSizes.spacing4),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 360),
                      child: Text(
                        title,
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: AppColors.secondary,
                          fontSize: 20,
                          height: 1.4,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSizes.spacing8),
                    Text(
                      description,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.secondary.withValues(alpha: 0.78),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: AppSizes.spacing24),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _LessonMeta(lesson: lesson),
                        const Spacer(),
                        _OpenLessonButton(
                          accent: accent,
                          isLocked: lesson.isLocked,
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

class _LessonIcon extends StatelessWidget {
  const _LessonIcon({required this.subjectId});

  final int subjectId;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Icon(
        _subjectIcon(subjectId),
        color: AppColors.secondary,
        size: 28,
      ),
    );
  }
}

class _RatingBadge extends StatelessWidget {
  const _RatingBadge({required this.rating});

  final double rating;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star, size: 16),
          const SizedBox(width: 4),
          Text(
            rating.toStringAsFixed(1),
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }
}

class _LessonMeta extends StatelessWidget {
  const _LessonMeta({required this.lesson});

  final LearningLessonModel lesson;

  @override
  Widget build(BuildContext context) {
    final parts = <String>[
      '${lesson.durationMinutes > 0 ? lesson.durationMinutes : 12} min',
      '${lesson.learnerCount > 0 ? lesson.learnerCount : 12} learners',
    ];

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.schedule_outlined, size: 18),
        const SizedBox(width: AppSizes.spacing4),
        Text(
          parts.isEmpty ? context.l10n.text('lessonsTitle') : parts.join(' · '),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.secondary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _OpenLessonButton extends StatelessWidget {
  const _OpenLessonButton({required this.accent, required this.isLocked});

  final Color accent;
  final bool isLocked;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: accent, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Icon(
        isLocked ? Icons.lock_outline : Icons.arrow_forward,
        color: AppColors.secondary,
      ),
    );
  }
}

class _LessonsError extends StatelessWidget {
  const _LessonsError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          const Icon(Icons.cloud_off_outlined, size: 40),
          const SizedBox(height: AppSizes.spacing12),
          Text(context.l10n.text('learningLessonsLoadFailed')),
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

class _EmptyLessons extends StatelessWidget {
  const _EmptyLessons();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Center(child: Text(context.l10n.text('learningLessonsEmpty'))),
    );
  }
}

class _SelectGradeMessage extends StatelessWidget {
  const _SelectGradeMessage();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Center(child: Text(context.l10n.text('selectGradeFirst'))),
    );
  }
}

String _subjectLabelKey(int subjectId) => switch (subjectId) {
  2 => 'subjectPhysics',
  3 => 'subjectChemistry',
  4 => 'subjectBiology',
  _ => 'subjectMath',
};

IconData _subjectIcon(int subjectId) => switch (subjectId) {
  2 => Icons.science,
  3 => Icons.biotech,
  4 => Icons.eco,
  _ => Icons.calculate,
};

String _fallbackCourseId(int subjectId) => switch (subjectId) {
  2 => 'force-motion',
  3 => 'chemistry-foundations',
  4 => 'biology-foundations',
  _ => 'algebra',
};

class _SubjectCategoryData {
  const _SubjectCategoryData({
    required this.id,
    required this.labelKey,
    required this.icon,
    required this.background,
    required this.foreground,
    required this.border,
  });

  final int id;
  final String labelKey;
  final IconData icon;
  final Color background;
  final Color foreground;
  final Color border;
}
