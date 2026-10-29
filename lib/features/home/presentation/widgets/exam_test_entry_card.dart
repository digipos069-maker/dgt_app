import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../localization/app_localizations.dart';
import '../../../../theme/app_colors.dart';
import '../../application/resource_controller.dart';
import '../pages/exam_test_list_page.dart';

/// The single "ប្រឡងតេស្ត" card at the bottom of the Resource page.
/// Tapping it opens [ExamTestListPage], which lists every test.
class ExamTestEntryCard extends ConsumerWidget {
  const ExamTestEntryCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    // Only used to show the count badge; the list page reuses this cache.
    final count = ref.watch(examTestsProvider).value?.total;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(AppSizes.cardRadius),
      clipBehavior: Clip.antiAlias,
      child: Ink(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.brandButton, AppColors.primary],
          ),
        ),
        child: InkWell(
          onTap: () => context.push(ExamTestListPage.routePath),
          child: Stack(
            children: [
              // Decorative circles.
              Positioned(
                right: -30,
                top: -30,
                child: const _Bubble(size: 120, alpha: 0.12),
              ),
              Positioned(
                right: 60,
                bottom: -40,
                child: const _Bubble(size: 90, alpha: 0.08),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSizes.spacing20),
                child: Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.35),
                        ),
                      ),
                      child: const Icon(
                        Icons.assignment_turned_in_outlined,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                    const SizedBox(width: AppSizes.spacing16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  l10n.text('examTestTitle'),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                              if (count != null && count > 0) ...[
                                const SizedBox(width: AppSizes.spacing8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Text(
                                    l10n
                                        .text('examTestCount')
                                        .replaceAll('{count}', '$count'),
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: AppColors.brandButton,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: AppSizes.spacing4),
                          Text(
                            l10n.text('examTestEntrySubtitle'),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.white.withValues(alpha: 0.9),
                              height: 1.45,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSizes.spacing8),
                    Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_forward_rounded,
                        color: AppColors.brandButton,
                        size: 20,
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
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.size, required this.alpha});

  final double size;
  final double alpha;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: alpha),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
