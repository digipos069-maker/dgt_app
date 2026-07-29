import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../localization/app_localizations.dart';
import '../../domain/models/resource_document_model.dart';
import 'resource_pdf_viewer.dart';
import 'resource_video_viewer.dart';

class ResourceDetailBody extends StatelessWidget {
  const ResourceDetailBody({required this.document, super.key});

  final ResourceDocumentModel document;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Theme(
      data: theme.copyWith(
        textTheme: GoogleFonts.battambangTextTheme(
          theme.textTheme,
        ).apply(fontSizeDelta: 3),
      ),
      child: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: 56,
              child: _ResourceDetailHeader(title: document.title),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  10,
                  AppSizes.spacing24,
                  10,
                  AppSizes.pageBottomPadding,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 896),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _ResourceIntroduction(document: document),
                        const SizedBox(height: AppSizes.spacing24),
                        if (document.type == ResourceDocumentType.pdf)
                          ResourcePdfViewer(document: document)
                        else
                          ResourceVideoViewer(document: document),
                        const SizedBox(height: AppSizes.spacing24),
                        _DocumentInformationCard(document: document),
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

class _ResourceDetailHeader extends StatelessWidget {
  const _ResourceDetailHeader({required this.title});

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

class _ResourceIntroduction extends StatelessWidget {
  const _ResourceIntroduction({required this.document});

  final ResourceDocumentModel document;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.spacing12,
                vertical: AppSizes.spacing8,
              ),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    document.type == ResourceDocumentType.pdf
                        ? Icons.picture_as_pdf_outlined
                        : Icons.play_circle_outline,
                    size: 18,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                  const SizedBox(width: AppSizes.spacing4),
                  Text(
                    document.type.label,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.spacing12),
        Text(
          document.title,
          style: theme.textTheme.headlineSmall?.copyWith(
            color: theme.colorScheme.secondary,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: AppSizes.spacing8),
        Text(
          document.description,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

class _DocumentInformationCard extends StatelessWidget {
  const _DocumentInformationCard({required this.document});

  final ResourceDocumentModel document;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(AppSizes.spacing20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        border: Border.all(
          color: theme.colorScheme.secondary.withValues(alpha: 0.2),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.text('resourceDocumentInformation'),
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.secondary,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: AppSizes.spacing16),
          Wrap(
            spacing: AppSizes.spacing24,
            runSpacing: AppSizes.spacing16,
            children: [
              _InformationItem(
                icon: Icons.school_outlined,
                label: context.l10n.text('resourceSubjectLabel'),
                value: document.subjectName,
              ),
              _InformationItem(
                icon: Icons.calendar_month_outlined,
                label: context.l10n.text('resourceYearLabel'),
                value: '${document.year}',
              ),
              _InformationItem(
                icon: Icons.description_outlined,
                label: context.l10n.text('resourceTypeLabel'),
                value: document.type.label,
              ),
              _InformationItem(
                icon: document.type == ResourceDocumentType.pdf
                    ? Icons.auto_stories_outlined
                    : Icons.schedule_outlined,
                label: document.type == ResourceDocumentType.pdf
                    ? context.l10n.text('resourcePagesLabel')
                    : context.l10n.text('resourceDurationLabel'),
                value: document.type == ResourceDocumentType.pdf
                    ? '${document.pageCount}'
                    : document.durationLabel,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InformationItem extends StatelessWidget {
  const _InformationItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: 170,
      child: Row(
        children: [
          Icon(icon, color: theme.colorScheme.primary),
          const SizedBox(width: AppSizes.spacing8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.secondary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
