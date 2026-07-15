import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../localization/app_localizations.dart';
import '../../../../theme/app_colors.dart';
import '../pages/lesson_list_page.dart';

class LearningCenterBody extends StatefulWidget {
  const LearningCenterBody({super.key});

  @override
  State<LearningCenterBody> createState() => _LearningCenterBodyState();
}

class _LearningCenterBodyState extends State<LearningCenterBody> {
  int _selectedGrade = 7;

  static const _grades = [7, 8, 9, 10, 11, 12];

  @override
  Widget build(BuildContext context) {
    const horizontalPadding = 10.0;
    final theme = Theme.of(context);
    final battambangTheme = GoogleFonts.battambangTextTheme(theme.textTheme);

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
                  const _LearningHeader(),
                  const SizedBox(height: AppSizes.spacing32),
                  _GradeSelector(
                    grades: _grades,
                    selectedGrade: _selectedGrade,
                    onChanged: (grade) =>
                        setState(() => _selectedGrade = grade),
                  ),
                  const SizedBox(height: AppSizes.spacing16),
                  const _SubjectCategoryStrip(),
                  const SizedBox(height: AppSizes.spacing24),
                  const _CourseCardList(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LearningHeader extends StatelessWidget {
  const _LearningHeader();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isWide = MediaQuery.sizeOf(context).width >= 720;

    final search = ConstrainedBox(
      constraints: BoxConstraints(maxWidth: isWide ? 380 : double.infinity),
      child: TextField(
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

    if (!isWide) {
      return search;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [const Spacer(), search],
    );
  }
}

class _GradeSelector extends StatelessWidget {
  const _GradeSelector({
    required this.grades,
    required this.selectedGrade,
    required this.onChanged,
  });

  final List<int> grades;
  final int selectedGrade;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final grade in grades) ...[
            _GradeChip(
              grade: grade,
              isSelected: grade == selectedGrade,
              onTap: () => onChanged(grade),
            ),
            const SizedBox(width: AppSizes.spacing12),
          ],
        ],
      ),
    );
  }
}

class _GradeChip extends StatelessWidget {
  const _GradeChip({
    required this.grade,
    required this.isSelected,
    required this.onTap,
  });

  final int grade;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ActionChip(
      onPressed: onTap,
      label: Text('${context.l10n.text('gradePrefix')} $grade'),
      labelStyle: theme.textTheme.titleMedium?.copyWith(
        color: isSelected
            ? theme.colorScheme.onPrimary
            : theme.colorScheme.onSurfaceVariant,
        fontWeight: FontWeight.w800,
      ),
      backgroundColor: isSelected
          ? theme.colorScheme.primary
          : theme.colorScheme.surfaceContainer,
      shape: const StadiumBorder(),
      side: BorderSide.none,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
    );
  }
}

class _SubjectCategoryStrip extends StatelessWidget {
  const _SubjectCategoryStrip();

  static const _subjects = [
    _SubjectCategoryData(
      labelKey: 'subjectMath',
      icon: Icons.calculate,
      background: Color(0xFFE0F2FE),
      foreground: AppColors.secondary,
      border: Color(0xFF7DD3FC),
    ),
    _SubjectCategoryData(
      labelKey: 'subjectPhysics',
      icon: Icons.science,
      background: Color(0xFFE8EDFA),
      foreground: AppColors.secondary,
      border: Color(0xFFB8C5E5),
    ),
    _SubjectCategoryData(
      labelKey: 'subjectChemistry',
      icon: Icons.biotech,
      background: Color(0xFFE0F2FE),
      foreground: AppColors.secondary,
      border: Color(0xFF7DD3FC),
    ),
    _SubjectCategoryData(
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
            _SubjectCategoryCard(subject: subject),
            const SizedBox(width: AppSizes.spacing16),
          ],
        ],
      ),
    );
  }
}

class _SubjectCategoryCard extends StatelessWidget {
  const _SubjectCategoryCard({required this.subject});

  final _SubjectCategoryData subject;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: subject.background,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () {},
        child: Container(
          width: 112,
          padding: const EdgeInsets.all(AppSizes.spacing16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: subject.border, width: 2),
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

class _CourseCardList extends StatelessWidget {
  const _CourseCardList();

  static const _courses = [
    _CourseCardData(
      courseId: 'algebra',
      subjectKey: 'subjectMath',
      titleKey: 'chapterAlgebra',
      icon: Icons.calculate,
      rating: '4.8',
      learners: '12+',
      background: Color(0xFFE0F2FE),
      foreground: AppColors.secondary,
      accent: AppColors.primary,
    ),
    _CourseCardData(
      courseId: 'force-motion',
      subjectKey: 'subjectPhysics',
      titleKey: 'chapterForceMotion',
      icon: Icons.science,
      rating: '4.5',
      learners: '8+',
      background: Color(0xFFE8EDFA),
      foreground: AppColors.secondary,
      accent: AppColors.secondary,
    ),
    _CourseCardData(
      courseId: 'narrative',
      subjectKey: 'subjectLiterature',
      titleKey: 'chapterNarrative',
      icon: Icons.language,
      rating: '4.9',
      learners: '20+',
      background: Color(0xFFE0F2FE),
      foreground: AppColors.secondary,
      accent: AppColors.primary,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final course in _courses) ...[
          _CourseCard(course: course),
          const SizedBox(height: AppSizes.spacing24),
        ],
      ],
    );
  }
}

class _CourseCard extends StatelessWidget {
  const _CourseCard({required this.course});

  final _CourseCardData course;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: course.background,
      borderRadius: BorderRadius.circular(32),
      child: InkWell(
        borderRadius: BorderRadius.circular(32),
        onTap: () => context.goNamed(
          LessonListPage.routeName,
          pathParameters: {'courseId': course.courseId},
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            border: Border.all(
              color: course.accent.withValues(alpha: 0.48),
              width: 2,
            ),
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
                        _CourseIcon(course: course),
                        const Spacer(),
                        _RatingBadge(rating: course.rating),
                      ],
                    ),
                    const SizedBox(height: AppSizes.spacing20),
                    Text(
                      context.l10n.text(course.subjectKey),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: course.foreground.withValues(alpha: 0.72),
                        fontSize: 14,
                        height: 1.42,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: AppSizes.spacing4),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 360),
                      child: Text(
                        context.l10n.text(course.titleKey),
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: course.foreground,
                          fontSize: 20,
                          height: 1.4,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSizes.spacing24),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _LearnerStack(course: course),
                        const Spacer(),
                        _OpenCourseButton(course: course),
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

class _CourseIcon extends StatelessWidget {
  const _CourseIcon({required this.course});

  final _CourseCardData course;

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
      child: Icon(course.icon, color: course.foreground, size: 28),
    );
  }
}

class _RatingBadge extends StatelessWidget {
  const _RatingBadge({required this.rating});

  final String rating;

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
          Text(rating, style: const TextStyle(fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}

class _LearnerStack extends StatelessWidget {
  const _LearnerStack({required this.course});

  final _CourseCardData course;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 92,
      height: 42,
      child: Stack(
        children: [
          _LearnerAvatar(
            left: 0,
            borderColor: course.background,
            color: Colors.white,
            label: 'A',
          ),
          _LearnerAvatar(
            left: 28,
            borderColor: course.background,
            color: course.accent.withValues(alpha: 0.72),
            label: course.learners,
          ),
        ],
      ),
    );
  }
}

class _LearnerAvatar extends StatelessWidget {
  const _LearnerAvatar({
    required this.left,
    required this.borderColor,
    required this.color,
    required this.label,
  });

  final double left;
  final Color borderColor;
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: borderColor, width: 2),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900),
        ),
      ),
    );
  }
}

class _OpenCourseButton extends StatelessWidget {
  const _OpenCourseButton({required this.course});

  final _CourseCardData course;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: course.accent, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Icon(Icons.arrow_forward, color: course.foreground),
    );
  }
}

class _CourseCardData {
  const _CourseCardData({
    required this.courseId,
    required this.subjectKey,
    required this.titleKey,
    required this.icon,
    required this.rating,
    required this.learners,
    required this.background,
    required this.foreground,
    required this.accent,
  });

  final String courseId;
  final String subjectKey;
  final String titleKey;
  final IconData icon;
  final String rating;
  final String learners;
  final Color background;
  final Color foreground;
  final Color accent;
}

class _SubjectCategoryData {
  const _SubjectCategoryData({
    required this.labelKey,
    required this.icon,
    required this.background,
    required this.foreground,
    required this.border,
  });

  final String labelKey;
  final IconData icon;
  final Color background;
  final Color foreground;
  final Color border;
}
