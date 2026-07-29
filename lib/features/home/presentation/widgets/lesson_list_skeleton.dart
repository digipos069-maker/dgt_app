import 'package:flutter/material.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/widgets/app_skeleton.dart';

class LessonListSkeleton extends StatelessWidget {
  const LessonListSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return AppSkeletonShimmer(
      child: SingleChildScrollView(
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
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _SummarySkeleton(),
                SizedBox(height: AppSizes.spacing32),
                AppSkeletonBox(width: 150, height: 28),
                SizedBox(height: AppSizes.spacing16),
                _LessonTileSkeleton(),
                SizedBox(height: AppSizes.spacing16),
                _LessonTileSkeleton(),
                SizedBox(height: AppSizes.spacing16),
                _LessonTileSkeleton(),
                SizedBox(height: AppSizes.spacing16),
                _LessonTileSkeleton(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SummarySkeleton extends StatelessWidget {
  const _SummarySkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(AppSizes.featureCardRadius),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary,
          width: 2,
        ),
      ),
      padding: const EdgeInsets.all(AppSizes.spacing24),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSkeletonBox.circle(size: 48),
          SizedBox(height: AppSizes.spacing24),
          AppSkeletonBox(width: 260, height: 28),
          SizedBox(height: AppSizes.spacing12),
          AppSkeletonBox(height: 15),
          SizedBox(height: AppSizes.spacing8),
          AppSkeletonBox(width: 360, height: 15),
        ],
      ),
    );
  }
}

class _LessonTileSkeleton extends StatelessWidget {
  const _LessonTileSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 82,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        border: Border.all(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          width: 2,
        ),
      ),
      padding: const EdgeInsets.all(AppSizes.spacing16),
      child: const Row(
        children: [
          AppSkeletonBox.circle(size: 48),
          SizedBox(width: AppSizes.spacing16),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppSkeletonBox(width: 240, height: 17),
                SizedBox(height: AppSizes.spacing8),
                AppSkeletonBox(width: 128, height: 13),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
