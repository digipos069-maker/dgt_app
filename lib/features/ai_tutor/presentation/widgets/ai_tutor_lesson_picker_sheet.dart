import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../localization/app_localizations.dart';
import '../../application/ai_tutor_controller.dart';
import '../../domain/models/ai_tutor_lesson_ref.dart';

/// Bottom sheet where the student searches and picks a lesson to give the
/// AI tutor as context. Returns the chosen lesson, or null if dismissed.
class AiTutorLessonPickerSheet extends ConsumerStatefulWidget {
  const AiTutorLessonPickerSheet({this.selected, super.key});

  final AiTutorLessonRef? selected;

  static Future<AiTutorLessonRef?> show(
    BuildContext context, {
    AiTutorLessonRef? selected,
  }) {
    return showModalBottomSheet<AiTutorLessonRef>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (_) => AiTutorLessonPickerSheet(selected: selected),
    );
  }

  @override
  ConsumerState<AiTutorLessonPickerSheet> createState() =>
      _AiTutorLessonPickerSheetState();
}

class _AiTutorLessonPickerSheetState extends ConsumerState<AiTutorLessonPickerSheet> {
  final _searchController = TextEditingController();
  Timer? _debounce;
  String _query = '';
  bool _allGrades = false;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      if (mounted) setState(() => _query = value.trim());
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final query = AiTutorLessonQuery(query: _query, allGrades: _allGrades);
    final results = ref.watch(aiTutorLessonSearchProvider(query));

    return Padding(
      // Keep the search field above the keyboard.
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.75,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.spacing20),
              child: Text(
                l10n.text('aiTutorPickLessonTitle'),
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
            ),
            const SizedBox(height: AppSizes.spacing12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.spacing16),
              child: TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: l10n.text('aiTutorPickLessonHint'),
                  prefixIcon: const Icon(Icons.search),
                  isDense: true,
                  filled: true,
                  fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSizes.cardRadius),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.spacing16,
                vertical: AppSizes.spacing8,
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: FilterChip(
                  label: Text(l10n.text('aiTutorAllGrades')),
                  selected: _allGrades,
                  onSelected: (value) => setState(() => _allGrades = value),
                ),
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: switch (results) {
                AsyncData(:final value) => _LessonList(
                  result: value,
                  selected: widget.selected,
                  onTryAllGrades: _allGrades ? null : () => setState(() => _allGrades = true),
                ),
                AsyncError() => _Message(
                  icon: Icons.cloud_off_outlined,
                  text: l10n.text('aiTutorLessonsLoadFailed'),
                  actionLabel: l10n.text('retry'),
                  onAction: () => ref.invalidate(aiTutorLessonSearchProvider(query)),
                ),
                _ => const Center(child: CircularProgressIndicator()),
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _LessonList extends StatelessWidget {
  const _LessonList({
    required this.result,
    required this.selected,
    required this.onTryAllGrades,
  });

  final AiTutorLessonSearchResult result;
  final AiTutorLessonRef? selected;
  final VoidCallback? onTryAllGrades;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    if (result.lessons.isEmpty) {
      return _Message(
        icon: Icons.menu_book_outlined,
        text: l10n.text('aiTutorNoLessons'),
        actionLabel: result.gradeFiltered && onTryAllGrades != null
            ? l10n.text('aiTutorTryAllGrades')
            : null,
        onAction: onTryAllGrades,
      );
    }

    final theme = Theme.of(context);
    final languageCode = Localizations.localeOf(context).languageCode;

    return ListView.separated(
      padding: const EdgeInsets.only(bottom: AppSizes.spacing24),
      itemCount: result.lessons.length,
      separatorBuilder: (_, _) => const Divider(height: 1, indent: 72),
      itemBuilder: (context, index) {
        final lesson = result.lessons[index];
        final isSelected = lesson == selected;
        final details = [
          lesson.subjectName(languageCode),
          if (lesson.grade != null) '${l10n.text('aiTutorGradeLabel')} ${lesson.grade}',
          lesson.chapter,
        ].whereType<String>().where((part) => part.trim().isNotEmpty).join(' · ');

        return ListTile(
          leading: CircleAvatar(
            backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.12),
            child: Icon(Icons.menu_book_rounded, color: theme.colorScheme.primary),
          ),
          title: Text(lesson.title, maxLines: 2, overflow: TextOverflow.ellipsis),
          subtitle: details.isEmpty
              ? null
              : Text(details, maxLines: 1, overflow: TextOverflow.ellipsis),
          trailing: isSelected
              ? Icon(Icons.check_circle, color: theme.colorScheme.primary)
              : null,
          selected: isSelected,
          onTap: () => Navigator.of(context).pop(lesson),
        );
      },
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({
    required this.icon,
    required this.text,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String text;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.spacing24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(height: AppSizes.spacing12),
            Text(
              text,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: AppSizes.spacing12),
              OutlinedButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}
