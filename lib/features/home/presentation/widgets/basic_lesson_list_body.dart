import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../localization/app_localizations.dart';
import '../../application/basic_course_controller.dart';
import '../../domain/models/basic_lesson_model.dart';
import '../pages/basic_course_page.dart';
import '../pages/basic_lesson_detail_page.dart';

class BasicLessonListBody extends ConsumerWidget {
  const BasicLessonListBody({required this.courseId, super.key});

  final String courseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final languageCode = Localizations.localeOf(context).languageCode;
    final request = BasicLessonsRequest(
      courseId: courseId,
      languageCode: languageCode,
    );
    final lessonsState = ref.watch(basicLessonsProvider(request));
    final theme = Theme.of(context);
    final textTheme = GoogleFonts.battambangTextTheme(
      theme.textTheme,
    ).apply(fontSizeDelta: 3);

    return Theme(
      data: theme.copyWith(textTheme: textTheme),
      child: lessonsState.when(
        data: (bundle) => _BasicLessonListContent(
          bundle: bundle,
          request: request,
        ),
        error: (_, _) => _BasicLessonListError(
          onRetry: () => ref.invalidate(basicLessonsProvider(request)),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

class _BasicLessonListContent extends ConsumerStatefulWidget {
  const _BasicLessonListContent({
    required this.bundle,
    required this.request,
  });

  final BasicLessonBundle bundle;
  final BasicLessonsRequest request;

  @override
  ConsumerState<_BasicLessonListContent> createState() =>
      _BasicLessonListContentState();
}

class _BasicLessonListContentState
    extends ConsumerState<_BasicLessonListContent> {
  static const int _initialLimit = 10;
  static const int _scrollLimit = 5;
  late int _visibleCount;
  late final ScrollController _scrollController;
  bool _isLoadingMore = false;
  Timer? _loadMoreTimer;

  @override
  void initState() {
    super.initState();
    _visibleCount = _initialLimit.clamp(0, widget.bundle.lessons.length);
    _scrollController = ScrollController()..addListener(_onScroll);
  }

  @override
  void didUpdateWidget(covariant _BasicLessonListContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    _isLoadingMore = false;
    if (oldWidget.bundle.lessons.length != widget.bundle.lessons.length) {
      _loadMoreTimer?.cancel();
      _visibleCount = widget.bundle.lessons.length;
    }
  }

  @override
  void dispose() {
    _loadMoreTimer?.cancel();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isLoadingMore || widget.bundle.isFetchingMore) return;

    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  void _loadMore() {
    if (_isLoadingMore || widget.bundle.isFetchingMore) return;

    // 1. If server pagination has more items, trigger API loadMore
    if (widget.bundle.hasMore) {
      setState(() {
        _isLoadingMore = true;
      });
      ref.read(basicLessonsProvider(widget.request).notifier).loadMore();
      return;
    }

    // 2. If client-side has buffered items not yet revealed
    if (_visibleCount < widget.bundle.lessons.length) {
      setState(() {
        _isLoadingMore = true;
      });

      _loadMoreTimer?.cancel();
      _loadMoreTimer = Timer(const Duration(milliseconds: 300), () {
        if (!mounted) return;
        setState(() {
          _visibleCount = (_visibleCount + _scrollLimit).clamp(
            0,
            widget.bundle.lessons.length,
          );
          _isLoadingMore = false;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final showLoading = widget.bundle.hasMore ||
        widget.bundle.isFetchingMore ||
        _visibleCount < widget.bundle.lessons.length;
    final totalCount = _visibleCount.clamp(0, widget.bundle.lessons.length);
    final itemCount = totalCount + 1 + (showLoading ? 1 : 0);

    return SafeArea(
      child: Column(
        children: [
          SizedBox(
            height: 56,
            child: _BasicLessonHeader(title: widget.bundle.course.name),
          ),
          Expanded(
            child: ListView.separated(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(
                10,
                24,
                10,
                AppSizes.pageBottomPadding,
              ),
              itemCount: itemCount,
              separatorBuilder: (_, _) =>
                  const SizedBox(height: AppSizes.spacing16),
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 760),
                      child: _CourseIntroduction(bundle: widget.bundle),
                    ),
                  );
                }

                if (index <= totalCount) {
                  final lesson = widget.bundle.lessons[index - 1];
                  return Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 760),
                      child: _BasicLessonTile(lesson: lesson),
                    ),
                  );
                }

                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: AppSizes.spacing16),
                  child: Center(
                    child: SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color(0xFF032EA1),
                        ),
                      ),
                    ),
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

class _BasicLessonHeader extends StatelessWidget {
  const _BasicLessonHeader({required this.title});

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
              onPressed: () => context.goNamed(BasicCoursePage.routeName),
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

class _CourseIntroduction extends StatelessWidget {
  const _CourseIntroduction({required this.bundle});

  final BasicLessonBundle bundle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.spacing8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.text('basicLessonsTitle'),
            style: theme.textTheme.headlineSmall?.copyWith(
              color: theme.colorScheme.secondary,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: AppSizes.spacing8),
          Text(
            bundle.course.description,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _BasicLessonTile extends StatelessWidget {
  const _BasicLessonTile({required this.lesson});

  final BasicLessonModel lesson;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.goNamed(
          BasicLessonDetailPage.routeName,
          pathParameters: {'courseId': lesson.courseId, 'lessonId': lesson.id},
        ),
        child: Container(
          height: 156,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.colorScheme.secondary.withValues(alpha: 0.24),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 116,
                height: 156,
                child: _LessonThumbnail(lesson: lesson),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(AppSizes.spacing16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        lesson.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.secondary,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: AppSizes.spacing4),
                      Text(
                        lesson.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: AppSizes.spacing8),
                      Row(
                        children: [
                          Icon(
                            Icons.schedule_outlined,
                            size: 17,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: AppSizes.spacing4),
                          Text(
                            lesson.durationLabel,
                            style: theme.textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Icon(Icons.chevron_right, color: theme.colorScheme.secondary),
              const SizedBox(width: AppSizes.spacing8),
            ],
          ),
        ),
      ),
    );
  }
}

class _LessonThumbnail extends StatelessWidget {
  const _LessonThumbnail({required this.lesson});

  final BasicLessonModel lesson;

  @override
  Widget build(BuildContext context) {
    return Image.network(
      lesson.thumbnail,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => ColoredBox(
        color: Theme.of(context).colorScheme.primaryContainer,
        child: Icon(
          Icons.menu_book_outlined,
          size: 42,
          color: Theme.of(context).colorScheme.onPrimaryContainer,
        ),
      ),
    );
  }
}

class _BasicLessonListError extends StatelessWidget {
  const _BasicLessonListError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(context.l10n.text('basicLessonLoadFailed')),
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
