import 'package:flutter/material.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/widgets/app_skeleton.dart';
import 'ai_tutor_avatar.dart';

/// Placeholder shown the first time the AI tutor opens, laid out like the real
/// page (allowance bar, welcome, lesson button, input) so nothing jumps when
/// the content appears.
class AiTutorChatSkeleton extends StatefulWidget {
  const AiTutorChatSkeleton({super.key});

  @override
  State<AiTutorChatSkeleton> createState() => _AiTutorChatSkeletonState();
}

class _AiTutorChatSkeletonState extends State<AiTutorChatSkeleton> {
  bool _precached = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Decode the logo while the skeleton is visible, so the avatar doesn't pop in.
    if (!_precached) {
      _precached = true;
      precacheAiTutorAvatars(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppSkeletonShimmer(
      child: Column(
        children: [
          // Allowance bar
          Container(
            color: theme.colorScheme.surface,
            padding: const EdgeInsets.fromLTRB(
              AppSizes.spacing16,
              AppSizes.spacing8,
              AppSizes.spacing16,
              AppSizes.spacing8,
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    AppSkeletonBox(width: 170, height: 12),
                    Spacer(),
                    AppSkeletonBox(width: 80, height: 10),
                  ],
                ),
                SizedBox(height: AppSizes.spacing4 + 2),
                AppSkeletonBox(height: 6, borderRadius: 4),
              ],
            ),
          ),
          // Welcome
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 896),
                child: ListView(
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(AppSizes.spacing24),
                  children: const [
                    SizedBox(height: AppSizes.spacing16),
                    Center(child: AppSkeletonBox.circle(size: 64)),
                    SizedBox(height: AppSizes.spacing16),
                    Center(child: AppSkeletonBox(width: 220, height: 22)),
                    SizedBox(height: AppSizes.spacing12),
                    Center(child: AppSkeletonBox(width: 280, height: 14)),
                    SizedBox(height: AppSizes.spacing8),
                    Center(child: AppSkeletonBox(width: 200, height: 14)),
                    SizedBox(height: AppSizes.spacing24),
                    Center(child: AppSkeletonBox(width: 190, height: 48, borderRadius: 24)),
                    SizedBox(height: AppSizes.spacing24),
                    Center(child: AppSkeletonBox(width: 240, height: 12)),
                  ],
                ),
              ),
            ),
          ),
          // Input bar
          Container(
            padding: const EdgeInsets.fromLTRB(
              AppSizes.spacing12,
              AppSizes.spacing8,
              AppSizes.spacing8,
              AppSizes.spacing8,
            ),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              border: Border(
                top: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.6)),
              ),
            ),
            child: const SafeArea(
              top: false,
              child: Row(
                children: [
                  Expanded(child: AppSkeletonBox(height: 46, borderRadius: AppSizes.cardRadius)),
                  SizedBox(width: AppSizes.spacing8),
                  AppSkeletonBox.circle(size: 44),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
