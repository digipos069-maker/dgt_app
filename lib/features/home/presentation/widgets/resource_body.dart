import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../localization/app_localizations.dart';
import '../../application/resource_controller.dart';
import '../../domain/models/exam_resource_model.dart';

class ResourceBody extends ConsumerWidget {
  const ResourceBody({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final languageCode = Localizations.localeOf(context).languageCode;
    final resourcesState = ref.watch(examResourcesProvider(languageCode));
    final theme = Theme.of(context);
    final textTheme = GoogleFonts.battambangTextTheme(theme.textTheme);

    return Theme(
      data: theme.copyWith(textTheme: textTheme),
      child: resourcesState.when(
        data: (resources) => _ResourceContent(
          resources: resources,
          onRefresh: () async {
            final _ = await ref.refresh(
              examResourcesProvider(languageCode).future,
            );
          },
        ),
        error: (_, _) => _ResourceError(
          onRetry: () => ref.invalidate(examResourcesProvider(languageCode)),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

class _ResourceContent extends StatelessWidget {
  const _ResourceContent({required this.resources, required this.onRefresh});

  final List<ExamResourceModel> resources;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    if (resources.isEmpty) {
      return const _EmptyResources();
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final columns = constraints.maxWidth >= 720 ? 2 : 1;

          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(10, 24, 10, 112),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const _ResourceIntroduction(),
                    const SizedBox(height: AppSizes.spacing24),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: resources.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: columns,
                        crossAxisSpacing: AppSizes.spacing16,
                        mainAxisSpacing: AppSizes.spacing16,
                        mainAxisExtent: 196,
                      ),
                      itemBuilder: (context, index) => _ResourceCard(
                        resource: resources[index],
                        index: index,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ResourceIntroduction extends StatelessWidget {
  const _ResourceIntroduction();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.text('resourceExamTitle'),
          style: theme.textTheme.headlineSmall?.copyWith(
            color: theme.colorScheme.secondary,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: AppSizes.spacing8),
        Text(
          context.l10n.text('resourceExamDescription'),
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

class _ResourceCard extends StatelessWidget {
  const _ResourceCard({required this.resource, required this.index});

  final ExamResourceModel resource;
  final int index;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final accent = index.isEven ? colors.primary : colors.secondary;
    final foreground = index.isEven
        ? colors.onPrimaryContainer
        : colors.onSecondaryContainer;
    final background = index.isEven
        ? colors.primaryContainer
        : colors.secondaryContainer;

    return Container(
      padding: const EdgeInsets.all(AppSizes.spacing16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        border: Border.all(
          color: resource.isLocked
              ? colors.outlineVariant
              : accent.withValues(alpha: 0.48),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: background,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  _resourceIcon(resource.icon),
                  color: foreground,
                  size: 28,
                ),
              ),
              const Spacer(),
              _AccessBadge(isLocked: resource.isLocked),
            ],
          ),
          const SizedBox(height: AppSizes.spacing16),
          Text(
            resource.examName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleLarge?.copyWith(
              color: colors.secondary,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: AppSizes.spacing8),
          Expanded(
            child: Text(
              resource.shortDescription,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AccessBadge extends StatelessWidget {
  const _AccessBadge({required this.isLocked});

  final bool isLocked;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final background = isLocked
        ? colors.surfaceContainerHighest
        : colors.primaryContainer;
    final foreground = isLocked
        ? colors.onSurfaceVariant
        : colors.onPrimaryContainer;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isLocked ? Icons.lock_outline : Icons.lock_open_outlined,
            size: 16,
            color: foreground,
          ),
          const SizedBox(width: AppSizes.spacing4),
          Text(
            context.l10n.text(
              isLocked ? 'resourceLocked' : 'resourceAccessible',
            ),
            style: theme.textTheme.labelSmall?.copyWith(
              color: foreground,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _ResourceError extends StatelessWidget {
  const _ResourceError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.spacing24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_off_outlined,
              size: 52,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: AppSizes.spacing16),
            Text(context.l10n.text('resourceLoadFailed')),
            const SizedBox(height: AppSizes.spacing16),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: Text(context.l10n.text('retry')),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyResources extends StatelessWidget {
  const _EmptyResources();

  @override
  Widget build(BuildContext context) {
    return Center(child: Text(context.l10n.text('resourceEmpty')));
  }
}

IconData _resourceIcon(String value) {
  return switch (value) {
    'trophy' => Icons.emoji_events_outlined,
    'medical' => Icons.medical_services_outlined,
    'teacher' => Icons.co_present_outlined,
    'engineering' => Icons.engineering_outlined,
    'certificate' => Icons.workspace_premium_outlined,
    _ => Icons.description_outlined,
  };
}
