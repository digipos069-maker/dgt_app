import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../localization/app_localizations.dart';
import '../../domain/models/resource_document_model.dart';

class ResourcePdfViewer extends StatefulWidget {
  const ResourcePdfViewer({required this.document, super.key});

  final ResourceDocumentModel document;

  @override
  State<ResourcePdfViewer> createState() => _ResourcePdfViewerState();
}

class _ResourcePdfViewerState extends State<ResourcePdfViewer> {
  final TransformationController _transformationController =
      TransformationController();
  int _currentPage = 1;
  double _scale = 1;

  int get _pageCount => math.max(widget.document.pageCount, 1);

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  void _changePage(int page) {
    setState(() => _currentPage = page.clamp(1, _pageCount));
    _resetZoom();
  }

  void _changeScale(double scale) {
    final nextScale = scale.clamp(0.8, 2.5);
    setState(() => _scale = nextScale);
    _transformationController.value = Matrix4.diagonal3Values(
      nextScale,
      nextScale,
      1,
    );
  }

  void _resetZoom() {
    setState(() => _scale = 1);
    _transformationController.value = Matrix4.identity();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        border: Border.all(
          color: theme.colorScheme.secondary.withValues(alpha: 0.2),
          width: 1.5,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          _PdfToolbar(
            currentPage: _currentPage,
            pageCount: _pageCount,
            scale: _scale,
            onZoomOut: () => _changeScale(_scale - 0.2),
            onZoomIn: () => _changeScale(_scale + 0.2),
            onReset: _resetZoom,
          ),
          Container(
            height: 560,
            color: const Color(0xFF29313D),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final pageWidth = math.min(constraints.maxWidth - 40, 390.0);

                return InteractiveViewer(
                  transformationController: _transformationController,
                  minScale: 0.8,
                  maxScale: 2.5,
                  boundaryMargin: const EdgeInsets.all(80),
                  child: Center(
                    child: SizedBox(
                      width: pageWidth,
                      height: pageWidth * 1.414,
                      child: _PdfPagePreview(
                        document: widget.document,
                        page: _currentPage,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          _PdfPageControls(
            currentPage: _currentPage,
            pageCount: _pageCount,
            onPrevious: _currentPage > 1
                ? () => _changePage(_currentPage - 1)
                : null,
            onNext: _currentPage < _pageCount
                ? () => _changePage(_currentPage + 1)
                : null,
          ),
        ],
      ),
    );
  }
}

class _PdfToolbar extends StatelessWidget {
  const _PdfToolbar({
    required this.currentPage,
    required this.pageCount,
    required this.scale,
    required this.onZoomOut,
    required this.onZoomIn,
    required this.onReset,
  });

  final int currentPage;
  final int pageCount;
  final double scale;
  final VoidCallback onZoomOut;
  final VoidCallback onZoomIn;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.spacing12,
        vertical: AppSizes.spacing8,
      ),
      child: Row(
        children: [
          Icon(Icons.picture_as_pdf_outlined, color: theme.colorScheme.primary),
          const SizedBox(width: AppSizes.spacing8),
          Expanded(
            child: Text(
              context.l10n.text('resourcePdfViewer'),
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.secondary,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          IconButton(
            tooltip: context.l10n.text('resourceZoomOut'),
            onPressed: onZoomOut,
            icon: const Icon(Icons.remove),
          ),
          Text(
            '${(scale * 100).round()}%',
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          IconButton(
            tooltip: context.l10n.text('resourceZoomIn'),
            onPressed: onZoomIn,
            icon: const Icon(Icons.add),
          ),
          IconButton(
            tooltip: context.l10n.text('resourceResetZoom'),
            onPressed: onReset,
            icon: const Icon(Icons.fit_screen_outlined),
          ),
        ],
      ),
    );
  }
}

class _PdfPagePreview extends StatelessWidget {
  const _PdfPagePreview({required this.document, required this.page});

  final ResourceDocumentModel document;
  final int page;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.white,
      elevation: 10,
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.spacing24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.school_outlined, color: theme.colorScheme.primary),
                const SizedBox(width: AppSizes.spacing8),
                Expanded(
                  child: Text(
                    document.subjectName,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.secondary,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                Text(
                  '${document.year}',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const Divider(height: AppSizes.spacing32),
            Text(
              document.title,
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.secondary,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: AppSizes.spacing12),
            Text(
              document.description,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),
            const SizedBox(height: AppSizes.spacing24),
            for (var index = 0; index < 7; index++) ...[
              Container(
                width: index.isEven ? double.infinity : 230,
                height: 8,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E8EC),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(height: AppSizes.spacing12),
            ],
            const Spacer(),
            Align(
              alignment: Alignment.center,
              child: Text(
                '$page',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PdfPageControls extends StatelessWidget {
  const _PdfPageControls({
    required this.currentPage,
    required this.pageCount,
    required this.onPrevious,
    required this.onNext,
  });

  final int currentPage;
  final int pageCount;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(AppSizes.spacing12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton.filledTonal(
            onPressed: onPrevious,
            icon: const Icon(Icons.chevron_left),
          ),
          const SizedBox(width: AppSizes.spacing16),
          Text(
            context.l10n
                .text('resourcePageOf')
                .replaceFirst('{current}', '$currentPage')
                .replaceFirst('{total}', '$pageCount'),
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.secondary,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(width: AppSizes.spacing16),
          IconButton.filledTonal(
            onPressed: onNext,
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }
}
