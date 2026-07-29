import 'package:flutter/material.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/widgets/app_skeleton.dart';

class LessonDetailSkeleton extends StatelessWidget {
  const LessonDetailSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return AppSkeletonShimmer(
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 56, child: _HeaderSkeleton()),
            Expanded(
              child: SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                  10,
                  AppSizes.spacing16,
                  10,
                  AppSizes.pageBottomPadding,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 896),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _VideoSkeleton(),
                        SizedBox(height: AppSizes.spacing32),
                        _QuizSkeleton(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderSkeleton extends StatelessWidget {
  const _HeaderSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(
              context,
            ).colorScheme.outlineVariant.withValues(alpha: 0.30),
          ),
        ),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.spacing16,
        vertical: AppSizes.spacing8,
      ),
      child: const Row(
        children: [
          AppSkeletonBox.circle(size: 40),
          Spacer(),
          AppSkeletonBox(width: 190, height: 20),
          Spacer(),
          AppSkeletonBox.circle(size: 40),
        ],
      ),
    );
  }
}

class _VideoSkeleton extends StatelessWidget {
  const _VideoSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AspectRatio(
          aspectRatio: 16 / 9,
          child: AppSkeletonBox(height: double.infinity, borderRadius: 12),
        ),
        SizedBox(height: AppSizes.spacing16),
        Row(
          children: [
            AppSkeletonBox(width: 112, height: 24, borderRadius: 6),
            SizedBox(width: AppSizes.spacing8),
            AppSkeletonBox(width: 92, height: 14),
          ],
        ),
        SizedBox(height: AppSizes.spacing12),
        AppSkeletonBox(width: 290, height: 28),
        SizedBox(height: AppSizes.spacing12),
        AppSkeletonBox(height: 15),
        SizedBox(height: AppSizes.spacing8),
        AppSkeletonBox(width: 620, height: 15),
      ],
    );
  }
}

class _QuizSkeleton extends StatelessWidget {
  const _QuizSkeleton();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(AppSizes.spacing24),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              AppSkeletonBox.circle(size: 40),
              SizedBox(width: AppSizes.spacing12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppSkeletonBox(width: 180, height: 24),
                    SizedBox(height: AppSizes.spacing8),
                    AppSkeletonBox(width: 260, height: 13),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: AppSizes.spacing32),
          _QuestionSkeleton(),
          SizedBox(height: AppSizes.spacing32),
          _QuestionSkeleton(),
        ],
      ),
    );
  }
}

class _QuestionSkeleton extends StatelessWidget {
  const _QuestionSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const AppSkeletonBox(width: 440, height: 18),
        const SizedBox(height: AppSizes.spacing16),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth >= 620 ? 2 : 1;
            return GridView.count(
              crossAxisCount: columns,
              crossAxisSpacing: AppSizes.spacing12,
              mainAxisSpacing: AppSizes.spacing12,
              mainAxisExtent: 64,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: const [
                AppSkeletonBox(height: 64),
                AppSkeletonBox(height: 64),
                AppSkeletonBox(height: 64),
                AppSkeletonBox(height: 64),
              ],
            );
          },
        ),
        const SizedBox(height: AppSizes.spacing16),
        const Align(
          alignment: Alignment.centerRight,
          child: AppSkeletonBox(width: 112, height: 40, borderRadius: 999),
        ),
      ],
    );
  }
}
