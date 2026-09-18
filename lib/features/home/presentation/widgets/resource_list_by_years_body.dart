import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../localization/app_localizations.dart';
import '../../application/resource_controller.dart';
import '../../domain/models/resource_document_model.dart';
import '../pages/resource_detail_page.dart';

const _brandPrimary = Color(0xFF032EA1);

class ResourceListByYearsBody extends ConsumerStatefulWidget {
  const ResourceListByYearsBody({
    required this.examId,
    required this.year,
    super.key,
  });

  final String examId;
  final int year;

  @override
  ConsumerState<ResourceListByYearsBody> createState() =>
      _ResourceListByYearsBodyState();
}

class _ResourceListByYearsBodyState
    extends ConsumerState<ResourceListByYearsBody> {
  String? _selectedSubjectId;
  String _searchKeyword = '';
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final request = _buildRequest();
      ref.read(resourcesByYearProvider(request).notifier).loadMore();
    }
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 350), () {
      if (mounted) {
        setState(() {
          _searchKeyword = query.trim();
        });
      }
    });
  }

  void _onClearSearch() {
    _searchController.clear();
    _debounceTimer?.cancel();
    setState(() {
      _searchKeyword = '';
    });
  }

  ResourcesByYearRequest _buildRequest() {
    return ResourcesByYearRequest(
      examId: widget.examId,
      year: widget.year,
      languageCode: Localizations.localeOf(context).languageCode,
      subjectId: _selectedSubjectId,
      search: _searchKeyword.isNotEmpty ? _searchKeyword : null,
    );
  }

  Future<void> _onRefresh() async {
    final request = _buildRequest();
    ref.invalidate(resourcesByYearProvider(request));
    try {
      await ref.read(resourcesByYearProvider(request).future);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final request = _buildRequest();
    final resourcesState = ref.watch(resourcesByYearProvider(request));
    final theme = Theme.of(context);

    return Theme(
      data: theme.copyWith(
        textTheme: GoogleFonts.battambangTextTheme(
          theme.textTheme,
        ).apply(fontSizeDelta: 3),
      ),
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(
          overscroll: false,
        ),
        child: resourcesState.when(
          data: (bundle) => _ResourceListContent(
            bundle: bundle,
            selectedSubjectId: _selectedSubjectId,
            searchController: _searchController,
            onSearchChanged: _onSearchChanged,
            onClearSearch: _onClearSearch,
            onSubjectSelected: (subjectId) {
              setState(() => _selectedSubjectId = subjectId);
            },
            onRefresh: _onRefresh,
            scrollController: _scrollController,
          ),
          error: (error, _) => _ResourceListError(
            errorMessage: error.toString(),
            onRetry: () => ref.invalidate(resourcesByYearProvider(request)),
          ),
          loading: () => const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(_brandPrimary),
            ),
          ),
        ),
      ),
    );
  }
}

class _ResourceListContent extends StatelessWidget {
  const _ResourceListContent({
    required this.bundle,
    required this.selectedSubjectId,
    required this.searchController,
    required this.onSearchChanged,
    required this.onClearSearch,
    required this.onSubjectSelected,
    required this.onRefresh,
    required this.scrollController,
  });

  final ResourceDocumentBundle bundle;
  final String? selectedSubjectId;
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onClearSearch;
  final ValueChanged<String?> onSubjectSelected;
  final Future<void> Function() onRefresh;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    final documents = bundle.documents;

    return SafeArea(
      child: Column(
        children: [
          SizedBox(
            height: 56,
            child: _ResourceListHeader(
              title: '${bundle.exam.examName} • ${bundle.year}',
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              color: _brandPrimary,
              onRefresh: onRefresh,
              child: ListView.separated(
                controller: scrollController,
                physics: const AlwaysScrollableScrollPhysics(
                  parent: ClampingScrollPhysics(),
                ),
                padding: const EdgeInsets.fromLTRB(
                  10,
                  24,
                  10,
                  AppSizes.pageBottomPadding,
                ),
                itemCount: documents.isEmpty ? 3 : documents.length + 3,
                separatorBuilder: (_, _) =>
                    const SizedBox(height: AppSizes.spacing16),
                itemBuilder: (context, index) {
                  final Widget item;
                  if (index == 0) {
                    item = _ResourceListIntroduction(year: bundle.year);
                  } else if (index == 1) {
                    item = _SubjectFilterCard(
                      subjects: bundle.subjects,
                      selectedSubjectId: selectedSubjectId,
                      searchController: searchController,
                      onSearchChanged: onSearchChanged,
                      onClearSearch: onClearSearch,
                      onSelected: onSubjectSelected,
                    );
                  } else if (documents.isEmpty) {
                    item = const _EmptySubjectResources();
                  } else if (index == documents.length + 2) {
                    item = bundle.hasMore
                        ? const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(_brandPrimary),
                              ),
                            ),
                          )
                        : const SizedBox.shrink();
                  } else {
                    item = _ResourceDocumentTile(document: documents[index - 2]);
                  }
                  return Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 760),
                      child: item,
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptySubjectResources extends StatelessWidget {
  const _EmptySubjectResources();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.spacing32),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.folder_open_outlined,
              size: 48,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(height: AppSizes.spacing12),
            Text(
              context.l10n.text('noResourcesForSubject'),
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResourceListHeader extends StatelessWidget {
  const _ResourceListHeader({required this.title});

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

class _ResourceListIntroduction extends StatelessWidget {
  const _ResourceListIntroduction({required this.year});

  final int year;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n
              .text('resourcesForYearTitle')
              .replaceFirst('{year}', '$year'),
          style: theme.textTheme.headlineSmall?.copyWith(
            color: theme.colorScheme.secondary,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: AppSizes.spacing8),
        Text(
          context.l10n.text('resourcesForYearDescription'),
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

class _SubjectFilterCard extends StatelessWidget {
  const _SubjectFilterCard({
    required this.subjects,
    required this.selectedSubjectId,
    required this.searchController,
    required this.onSearchChanged,
    required this.onClearSearch,
    required this.onSelected,
  });

  final List<ResourceSubjectModel> subjects;
  final String? selectedSubjectId;
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onClearSearch;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.spacing16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        border: Border.all(
          color: _brandPrimary.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search Input
          TextField(
            controller: searchController,
            onChanged: onSearchChanged,
            decoration: InputDecoration(
              hintText: 'ស្វែងរកឯកសារ ឬចំណងជើង...',
              hintStyle: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
              ),
              prefixIcon: const Icon(Icons.search, color: _brandPrimary),
              suffixIcon: searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 20),
                      onPressed: onClearSearch,
                    )
                  : null,
              filled: true,
              fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: _brandPrimary.withValues(alpha: 0.2)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: _brandPrimary, width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: AppSizes.spacing16),
          Row(
            children: [
              const Icon(Icons.filter_alt_outlined, color: _brandPrimary),
              const SizedBox(width: AppSizes.spacing8),
              Text(
                context.l10n.text('filterBySubject'),
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.secondary,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.spacing12),
          Wrap(
            spacing: AppSizes.spacing8,
            runSpacing: AppSizes.spacing8,
            children: [
              FilterChip(
                label: Text(
                  context.l10n.text('allSubjects'),
                  style: TextStyle(
                    color: selectedSubjectId == null ? Colors.white : theme.colorScheme.onSurface,
                    fontWeight: selectedSubjectId == null ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                selected: selectedSubjectId == null,
                selectedColor: _brandPrimary,
                checkmarkColor: Colors.white,
                backgroundColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                onSelected: (_) => onSelected(null),
              ),
              for (final subject in subjects)
                FilterChip(
                  label: Text(
                    subject.name,
                    style: TextStyle(
                      color: selectedSubjectId == subject.id
                          ? Colors.white
                          : theme.colorScheme.onSurface,
                      fontWeight: selectedSubjectId == subject.id
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                  selected: selectedSubjectId == subject.id,
                  selectedColor: _brandPrimary,
                  checkmarkColor: Colors.white,
                  backgroundColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                  onSelected: (_) => onSelected(subject.id),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ResourceDocumentTile extends StatelessWidget {
  const _ResourceDocumentTile({required this.document});

  final ResourceDocumentModel document;

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
            builder: (_) => ResourceDetailPage(document: document),
          ),
        ),
        child: Container(
          height: 156,
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
                width: 116,
                height: 156,
                decoration: const BoxDecoration(
                  color: Color(0xFFE8EEFC),
                  borderRadius: BorderRadius.horizontal(
                    left: Radius.circular(AppSizes.cardRadius),
                  ),
                ),
                child: Icon(
                  document.type == ResourceDocumentType.pdf
                      ? Icons.picture_as_pdf_outlined
                      : Icons.play_circle_outline,
                  size: 44,
                  color: _brandPrimary,
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(AppSizes.spacing16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        document.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.secondary,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: AppSizes.spacing4),
                      Text(
                        document.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: AppSizes.spacing8),
                      Text(
                        '${document.subjectName} • ${document.type.label}',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: _brandPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: theme.colorScheme.secondary,
              ),
              const SizedBox(width: AppSizes.spacing8),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResourceListError extends StatelessWidget {
  const _ResourceListError({
    required this.onRetry,
    this.errorMessage,
  });

  final VoidCallback onRetry;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.spacing24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_outlined,
              size: 56,
              color: _brandPrimary,
            ),
            const SizedBox(height: AppSizes.spacing16),
            Text(
              context.l10n.text('resourcesForYearLoadFailed'),
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            if (errorMessage != null && errorMessage!.isNotEmpty) ...[
              const SizedBox(height: AppSizes.spacing8),
              Text(
                errorMessage!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ],
            const SizedBox(height: AppSizes.spacing16),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: _brandPrimary,
                foregroundColor: Colors.white,
              ),
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

