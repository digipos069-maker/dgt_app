import 'dart:developer' as developer;
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import '../../../../core/constants/api_constants.dart';
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
  late PdfViewerController _pdfViewerController;
  Key _pdfViewerKey = UniqueKey();
  int _currentPage = 1;
  int _pageCount = 1;
  double _scale = 1.0;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _pdfViewerController = PdfViewerController();
    _pageCount = math.max(widget.document.pageCount, 1);
  }

  @override
  void didUpdateWidget(covariant ResourcePdfViewer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.document.sourceUrl != widget.document.sourceUrl) {
      _retry();
    }
  }

  @override
  void dispose() {
    _pdfViewerController.dispose();
    super.dispose();
  }

  void _retry() {
    setState(() {
      _hasError = false;
      _isLoading = true;
      _currentPage = 1;
      _scale = 1.0;
      _pdfViewerKey = UniqueKey();
    });
  }

  String? _resolvePdfUrl() {
    final raw = widget.document.sourceUrl.trim();
    if (raw.isEmpty) return null;
    final resolved = raw.startsWith('/') ? '${ApiConstants.baseUrl}$raw' : raw;
    final uri = Uri.tryParse(resolved);
    if (uri == null || !uri.hasScheme) return null;
    return resolved;
  }

  void _zoomIn() {
    final nextScale = (_pdfViewerController.zoomLevel + 0.25).clamp(1.0, 3.0);
    _pdfViewerController.zoomLevel = nextScale;
    setState(() => _scale = nextScale);
  }

  void _zoomOut() {
    final nextScale = (_pdfViewerController.zoomLevel - 0.25).clamp(1.0, 3.0);
    _pdfViewerController.zoomLevel = nextScale;
    setState(() => _scale = nextScale);
  }

  void _resetZoom() {
    _pdfViewerController.zoomLevel = 1.0;
    setState(() => _scale = 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final resolvedUrl = _resolvePdfUrl();

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
            scale: _scale,
            onZoomOut: (!_hasError && _scale > 1.0) ? _zoomOut : null,
            onZoomIn: (!_hasError && _scale < 3.0) ? _zoomIn : null,
            onReset:
                (!_hasError && (_scale - 1.0).abs() > 0.01) ? _resetZoom : null,
          ),
          Container(
            height: 560,
            color: const Color(0xFF29313D),
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (resolvedUrl != null && !_hasError)
                  Positioned.fill(
                    child: ClipRect(
                      child: SfPdfViewer.network(
                        resolvedUrl,
                        key: _pdfViewerKey,
                        controller: _pdfViewerController,
                        canShowScrollHead: false,
                        canShowScrollStatus: false,
                        canShowPaginationDialog: false,
                        canShowPageLoadingIndicator: false,
                        onDocumentLoaded: (PdfDocumentLoadedDetails details) {
                          if (mounted) {
                            setState(() {
                              _isLoading = false;
                              _pageCount = math.max(
                                details.document.pages.count,
                                1,
                              );
                            });
                          }
                        },
                        onDocumentLoadFailed:
                            (PdfDocumentLoadFailedDetails details) {
                              developer.log(
                                'Failed to load PDF from $resolvedUrl: ${details.error} - ${details.description}',
                                name: 'dgt.pdf',
                              );
                              if (mounted) {
                                setState(() {
                                  _isLoading = false;
                                  _hasError = true;
                                });
                              }
                            },
                        onPageChanged: (PdfPageChangedDetails details) {
                          if (mounted) {
                            setState(() {
                              _currentPage = details.newPageNumber;
                            });
                          }
                        },
                        onZoomLevelChanged: (PdfZoomDetails details) {
                          if (mounted) {
                            setState(() {
                              _scale = details.newZoomLevel;
                            });
                          }
                        },
                      ),
                    ),
                  ),
                if (_isLoading && !_hasError && resolvedUrl != null)
                  const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                if (_hasError || resolvedUrl == null)
                  _PdfError(onRetry: _retry),
              ],
            ),
          ),
          _PdfPageControls(
            currentPage: _currentPage,
            pageCount: _pageCount,
            onPrevious: (!_hasError && _currentPage > 1)
                ? () => _pdfViewerController.previousPage()
                : null,
            onNext: (!_hasError && _currentPage < _pageCount)
                ? () => _pdfViewerController.nextPage()
                : null,
          ),
        ],
      ),
    );
  }
}

class _PdfToolbar extends StatelessWidget {
  const _PdfToolbar({
    required this.scale,
    required this.onZoomOut,
    required this.onZoomIn,
    required this.onReset,
  });

  final double scale;
  final VoidCallback? onZoomOut;
  final VoidCallback? onZoomIn;
  final VoidCallback? onReset;

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
          IconButton.filled(
            style: IconButton.styleFrom(
              backgroundColor: const Color(0xFF032EA1),
              foregroundColor: Colors.white,
              disabledBackgroundColor: const Color(
                0xFF032EA1,
              ).withValues(alpha: 0.38),
              disabledForegroundColor: Colors.white38,
            ),
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
          IconButton.filled(
            style: IconButton.styleFrom(
              backgroundColor: const Color(0xFF032EA1),
              foregroundColor: Colors.white,
              disabledBackgroundColor: const Color(
                0xFF032EA1,
              ).withValues(alpha: 0.38),
              disabledForegroundColor: Colors.white38,
            ),
            onPressed: onNext,
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }
}

class _PdfError extends StatelessWidget {
  const _PdfError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.spacing24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.picture_as_pdf_outlined,
              color: Colors.white70,
              size: 48,
            ),
            const SizedBox(height: AppSizes.spacing12),
            Text(
              context.l10n.text('resourcePdfLoadFailed'),
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.white),
            ),
            const SizedBox(height: AppSizes.spacing16),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF032EA1),
                foregroundColor: Colors.white,
              ),
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, size: 18),
              label: Text(context.l10n.text('retry')),
            ),
          ],
        ),
      ),
    );
  }
}
