import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../localization/app_localizations.dart';
import '../../../../theme/app_colors.dart';
import '../../../home/presentation/pages/learning_center_page.dart';
import '../../application/grade_controller.dart';

class HomeSubjectGrid extends ConsumerStatefulWidget {
  const HomeSubjectGrid({super.key});

  @override
  ConsumerState<HomeSubjectGrid> createState() => _HomeSubjectGridState();
}

class _HomeSubjectGridState extends ConsumerState<HomeSubjectGrid> {
  int? _openingSubjectId;

  Future<void> _openSubject(int subjectId) async {
    if (_openingSubjectId != null) return;
    setState(() => _openingSubjectId = subjectId);
    try {
      final grades = await ref.read(gradesProvider.future);
      final grade = grades.where((grade) => grade.number == 12).firstOrNull;
      if (grade == null) throw StateError('Grade 12 is unavailable');
      if (!mounted) return;
      context.pushNamed(
        LearningCenterPage.routeName,
        queryParameters: {
          'gradeId': grade.id.toString(),
          'gradeNumber': grade.number.toString(),
          'subjectId': subjectId.toString(),
        },
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.text('gradesLoadFailed')),
          action: SnackBarAction(
            label: context.l10n.text('retry'),
            onPressed: () {
              ref.invalidate(gradesProvider);
              _openSubject(subjectId);
            },
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _openingSubjectId = null);
    }
  }

  static const _subjects = [
    _SubjectItem(1, 'homeSubjectMath', Icons.calculate, AppColors.secondary),
    _SubjectItem(3, 'homeSubjectChemistry', Icons.science, AppColors.primary),
    _SubjectItem(4, 'homeSubjectBiology', Icons.biotech, AppColors.secondary),
    _SubjectItem(
      2,
      'homeSubjectPhysics',
      Icons.rocket_launch,
      AppColors.secondary,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final columns = width >= 920 ? 4 : 2;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _subjects.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: AppSizes.spacing16,
        mainAxisSpacing: AppSizes.spacing16,
        childAspectRatio: width >= 620 ? 1.05 : 1.15,
      ),
      itemBuilder: (context, index) {
        final subject = _subjects[index];
        return _SubjectTile(
          subject: subject,
          isLoading: _openingSubjectId == subject.id,
          onTap: _openingSubjectId == null
              ? () => _openSubject(subject.id)
              : null,
        );
      },
    );
  }
}

class _SubjectTile extends StatelessWidget {
  const _SubjectTile({
    required this.subject,
    required this.isLoading,
    this.onTap,
  });

  final _SubjectItem subject;
  final bool isLoading;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: subject.color.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: subject.color.withValues(alpha: 0.22),
              width: 2,
            ),
          ),
          padding: const EdgeInsets.all(AppSizes.spacing16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: subject.color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: isLoading
                    ? const Padding(
                        padding: EdgeInsets.all(AppSizes.spacing12),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(subject.icon, color: subject.color, size: 30),
              ),
              const SizedBox(height: AppSizes.spacing12),
              Text(
                context.l10n.text(subject.titleKey),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SubjectItem {
  const _SubjectItem(this.id, this.titleKey, this.icon, this.color);

  final int id;
  final String titleKey;
  final IconData icon;
  final Color color;
}
