import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../localization/app_localizations.dart';
import '../../application/resource_controller.dart';
import '../../domain/models/resource_year_model.dart';
import '../pages/resource_list_by_years_page.dart';

class ResourceYearsBody extends ConsumerWidget {
  const ResourceYearsBody({required this.examId, super.key});

  final String examId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final request = ResourceYearsRequest(
      examId: examId,
      languageCode: Localizations.localeOf(context).languageCode,
    );
    final yearsState = ref.watch(resourceYearsProvider(request));
    final theme = Theme.of(context);

    return Theme(
      data: theme.copyWith(
        textTheme: GoogleFonts.battambangTextTheme(
          theme.textTheme,
        ).apply(fontSizeDelta: 3),
      ),
      child: yearsState.when(
        data: (bundle) => _ResourceYearsContent(bundle: bundle),
        error: (_, _) => _ResourceYearsError(
          onRetry: () => ref.invalidate(resourceYearsProvider(request)),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

class _ResourceYearsContent extends StatelessWidget {
  const _ResourceYearsContent({required this.bundle});

  final ResourceYearBundle bundle;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          SizedBox(
            height: 56,
            child: _ResourceYearsHeader(title: bundle.exam.examName),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(
                10,
                24,
                10,
                AppSizes.pageBottomPadding,
              ),
              itemCount: bundle.years.length + 1,
              separatorBuilder: (_, _) =>
                  const SizedBox(height: AppSizes.spacing16),
              itemBuilder: (context, index) {
                final item = index == 0
                    ? const _YearsIntroduction()
                    : _ResourceYearTile(
                        examId: bundle.exam.id,
                        year: bundle.years[index - 1],
                      );
                return Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 760),
                    child: item,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ResourceYearsHeader extends StatelessWidget {
  const _ResourceYearsHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ColoredBox(
      color: theme.colorScheme.surface.withValues(alpha: 0.94),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          children: [
            IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back),
              color: theme.colorScheme.secondary,
            ),
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.secondary,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(width: 48),
          ],
        ),
      ),
    );
  }
}

class _YearsIntroduction extends StatelessWidget {
  const _YearsIntroduction();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.text('resourceYearsTitle'),
          style: theme.textTheme.headlineSmall?.copyWith(
            color: theme.colorScheme.secondary,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: AppSizes.spacing8),
        Text(
          context.l10n.text('resourceYearsDescription'),
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

class _ResourceYearTile extends StatelessWidget {
  const _ResourceYearTile({required this.examId, required this.year});

  final String examId;
  final ResourceYearModel year;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(AppSizes.cardRadius),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) =>
                ResourceListByYearsPage(examId: examId, year: year.year),
          ),
        ),
        child: Container(
          height: 112,
          padding: const EdgeInsets.all(AppSizes.spacing16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSizes.cardRadius),
            border: Border.all(
              color: theme.colorScheme.secondary.withValues(alpha: 0.24),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 72,
                height: 72,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.calendar_month_outlined,
                  size: 34,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: AppSizes.spacing16),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      year.year.toString(),
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: theme.colorScheme.secondary,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: AppSizes.spacing4),
                    Text(
                      context.l10n
                          .text('resourceCount')
                          .replaceFirst('{count}', '${year.resourceCount}'),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: theme.colorScheme.secondary),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResourceYearsError extends StatelessWidget {
  const _ResourceYearsError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(context.l10n.text('resourceYearsLoadFailed')),
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
