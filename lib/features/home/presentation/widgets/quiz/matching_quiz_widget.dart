import 'package:flutter/material.dart';

import 'package:dgt_app/core/constants/app_sizes.dart';
import 'package:dgt_app/core/widgets/mixed_latex_text.dart';
import 'package:dgt_app/features/home/domain/models/quiz_models.dart';
import 'package:dgt_app/localization/app_localizations.dart';
import 'package:dgt_app/theme/app_colors.dart';
import 'quiz_button.dart';

class MatchingQuizWidget extends StatefulWidget {
  const MatchingQuizWidget({
    required this.number,
    required this.data,
    this.initialMatches,
    this.onMatchesChanged,
    this.onSubmit,
    this.isSubmitting = false,
    this.isSubmitted = false,
    this.showValidation = false,
    super.key,
  });

  final int number;
  final MatchingQuizData data;
  final Map<String, String>? initialMatches;
  final ValueChanged<Map<String, String>>? onMatchesChanged;
  final ValueChanged<Map<String, String>>? onSubmit;
  final bool isSubmitting;
  final bool isSubmitted;
  final bool showValidation;

  @override
  State<MatchingQuizWidget> createState() => _MatchingQuizWidgetState();
}

class _MatchingQuizWidgetState extends State<MatchingQuizWidget> {
  late Map<String, String> _userMatches;
  String? _selectedStemId;

  // Pair badge colors to distinguish different paired stems
  static const _pairPalette = [
    Color(0xFF2563EB),
    Color(0xFF7C3AED),
    Color(0xFFD97706),
    Color(0xFF0D9488),
    Color(0xFFDC2626),
    Color(0xFF4F46E5),
  ];

  @override
  void initState() {
    super.initState();
    _userMatches = Map<String, String>.from(widget.initialMatches ?? {});
  }

  @override
  void didUpdateWidget(covariant MatchingQuizWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialMatches != null &&
        widget.initialMatches != oldWidget.initialMatches) {
      _userMatches = Map<String, String>.from(widget.initialMatches!);
    }
  }

  void _onStemTap(String stemId) {
    if (widget.isSubmitted || widget.isSubmitting) return;

    setState(() {
      if (_selectedStemId == stemId) {
        // Deselect if already selected
        _selectedStemId = null;
      } else if (_userMatches.containsKey(stemId)) {
        // Unpair if tapped an already paired stem
        _userMatches.remove(stemId);
        _selectedStemId = stemId;
        widget.onMatchesChanged?.call(_userMatches);
      } else {
        _selectedStemId = stemId;
      }
    });
  }

  void _onOptionTap(String optionId) {
    if (widget.isSubmitted || widget.isSubmitting) return;

    final activeStemId = _selectedStemId;
    if (activeStemId == null) {
      // If an option is already matched, tapping it unpairs
      final stemForThisOption = _findStemForOption(optionId);
      if (stemForThisOption != null) {
        setState(() {
          _userMatches.remove(stemForThisOption);
          widget.onMatchesChanged?.call(_userMatches);
        });
      }
      return;
    }

    setState(() {
      // If this option was previously mapped to another stem, unassign it
      _userMatches.removeWhere((_, value) => value == optionId);

      // Assign to currently selected stem
      _userMatches[activeStemId] = optionId;
      _selectedStemId = null;
      widget.onMatchesChanged?.call(_userMatches);
    });
  }

  String? _findStemForOption(String optionId) {
    for (final entry in _userMatches.entries) {
      if (entry.value == optionId) return entry.key;
    }
    return null;
  }

  Color _badgeColorForStemIndex(int index) {
    return _pairPalette[index % _pairPalette.length];
  }

  void _handleReset() {
    setState(() {
      _userMatches.clear();
      _selectedStemId = null;
    });
    widget.onMatchesChanged?.call(_userMatches);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final questionPrefix = context.l10n.text('questionPrefix');
    final description = widget.data.description;
    final allPaired = _userMatches.length == widget.data.stems.length &&
        widget.data.stems.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$questionPrefix${widget.number}. ',
              style: TextStyle(
                color: theme.colorScheme.secondary,
                fontWeight: FontWeight.w900,
                fontSize: 16,
              ),
            ),
            Expanded(
              child: MixedLatexText(
                text: description.isNotEmpty
                    ? description
                    : context.l10n.text('matchingQuizTitle'),
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            if (!widget.isSubmitted && _userMatches.isNotEmpty)
              TextButton.icon(
                onPressed: widget.isSubmitting ? null : _handleReset,
                icon: const Icon(Icons.refresh, size: 16),
                label: Text(
                  context.l10n.text('clear'),
                  style: const TextStyle(fontSize: 12),
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSizes.spacing8),
        Text(
          'Tap a term, then tap a matching definition to connect them.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontStyle: FontStyle.italic,
          ),
        ),
        const SizedBox(height: AppSizes.spacing16),
        LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 540;
            if (isWide) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _buildStemsColumn(theme)),
                  const SizedBox(width: AppSizes.spacing16),
                  Expanded(child: _buildOptionsColumn(theme)),
                ],
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildStemsColumn(theme),
                const SizedBox(height: AppSizes.spacing16),
                _buildOptionsColumn(theme),
              ],
            );
          },
        ),
        const SizedBox(height: AppSizes.spacing16),
        if (widget.onSubmit != null)
          Align(
            alignment: Alignment.centerRight,
            child: QuizButton(
              onPressed: widget.isSubmitting || !allPaired
                  ? null
                  : () => widget.onSubmit?.call(_userMatches),
              isLoading: widget.isSubmitting,
              isCompleted: widget.isSubmitted,
              icon: widget.isSubmitted
                  ? Icons.check_circle_outline
                  : Icons.send_outlined,
              label: context.l10n.text(
                widget.isSubmitted ? 'quizSubmitted' : 'submitQuiz',
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildStemsColumn(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Terms',
          style: theme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: theme.colorScheme.secondary,
          ),
        ),
        const SizedBox(height: AppSizes.spacing8),
        for (final (index, stem) in widget.data.stems.indexed) ...[
          if (index > 0) const SizedBox(height: AppSizes.spacing8),
          _StemCard(
            index: index,
            stem: stem,
            isSelected: _selectedStemId == stem.id,
            matchedOptionId: _userMatches[stem.id],
            badgeColor: _badgeColorForStemIndex(index),
            isValidationVisible: widget.showValidation || widget.isSubmitted,
            isCorrect: widget.data.isMatchCorrect(
              stem.id,
              _userMatches[stem.id] ?? '',
            ),
            onTap: () => _onStemTap(stem.id),
          ),
        ],
      ],
    );
  }

  Widget _buildOptionsColumn(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Definitions',
          style: theme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: theme.colorScheme.secondary,
          ),
        ),
        const SizedBox(height: AppSizes.spacing8),
        for (final (index, option) in widget.data.options.indexed) ...[
          if (index > 0) const SizedBox(height: AppSizes.spacing8),
          _buildOptionCard(option, index),
        ],
      ],
    );
  }

  Widget _buildOptionCard(MatchingOption option, int index) {
    final matchedStemId = _findStemForOption(option.id);
    final stemIndex = matchedStemId != null
        ? widget.data.stems.indexWhere((s) => s.id == matchedStemId)
        : -1;
    final badgeColor = stemIndex >= 0 ? _badgeColorForStemIndex(stemIndex) : null;
    final isValidation = widget.showValidation || widget.isSubmitted;
    final isCorrect = matchedStemId != null &&
        widget.data.isMatchCorrect(matchedStemId, option.id);

    return _OptionMatchCard(
      option: option,
      matchedStemIndex: stemIndex >= 0 ? stemIndex + 1 : null,
      badgeColor: badgeColor,
      isValidationVisible: isValidation,
      isCorrect: isCorrect,
      isHighlighted: _selectedStemId != null && matchedStemId == null,
      onTap: () => _onOptionTap(option.id),
    );
  }
}

class _StemCard extends StatelessWidget {
  const _StemCard({
    required this.index,
    required this.stem,
    required this.isSelected,
    required this.matchedOptionId,
    required this.badgeColor,
    required this.isValidationVisible,
    required this.isCorrect,
    required this.onTap,
  });

  final int index;
  final QuizStem stem;
  final bool isSelected;
  final String? matchedOptionId;
  final Color badgeColor;
  final bool isValidationVisible;
  final bool isCorrect;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMatched = matchedOptionId != null;

    Color borderColor = theme.colorScheme.outlineVariant;
    Color bgColor = theme.colorScheme.surface;

    if (isValidationVisible && isMatched) {
      borderColor = isCorrect ? AppColors.success : AppColors.error;
      bgColor = (isCorrect ? AppColors.success : AppColors.error).withValues(alpha: 0.08);
    } else if (isSelected) {
      borderColor = theme.colorScheme.primary;
      bgColor = theme.colorScheme.primary.withValues(alpha: 0.09);
    } else if (isMatched) {
      borderColor = badgeColor.withValues(alpha: 0.6);
      bgColor = badgeColor.withValues(alpha: 0.06);
    }

    return Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(AppSizes.cardRadius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.spacing12,
            vertical: AppSizes.spacing12,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSizes.cardRadius),
            border: Border.all(
              color: borderColor,
              width: isSelected || isMatched ? 1.8 : 1.0,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: isMatched
                      ? badgeColor
                      : theme.colorScheme.surfaceContainerHighest,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: isMatched ? Colors.white : theme.colorScheme.onSurface,
                  ),
                ),
              ),
              const SizedBox(width: AppSizes.spacing12),
              Expanded(
                child: MixedLatexText(
                  text: stem.text,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
              if (isValidationVisible && isMatched)
                Icon(
                  isCorrect ? Icons.check_circle : Icons.cancel,
                  color: isCorrect ? AppColors.success : AppColors.error,
                  size: 20,
                )
              else if (isMatched)
                Icon(Icons.link, color: badgeColor, size: 18)
              else if (isSelected)
                Icon(Icons.arrow_forward, color: theme.colorScheme.primary, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}

class _OptionMatchCard extends StatelessWidget {
  const _OptionMatchCard({
    required this.option,
    required this.matchedStemIndex,
    required this.badgeColor,
    required this.isValidationVisible,
    required this.isCorrect,
    required this.isHighlighted,
    required this.onTap,
  });

  final MatchingOption option;
  final int? matchedStemIndex;
  final Color? badgeColor;
  final bool isValidationVisible;
  final bool isCorrect;
  final bool isHighlighted;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMatched = matchedStemIndex != null;

    Color borderColor = theme.colorScheme.outlineVariant;
    Color bgColor = theme.colorScheme.surface;

    if (isValidationVisible && isMatched) {
      borderColor = isCorrect ? AppColors.success : AppColors.error;
      bgColor = (isCorrect ? AppColors.success : AppColors.error).withValues(alpha: 0.08);
    } else if (isMatched && badgeColor != null) {
      borderColor = badgeColor!.withValues(alpha: 0.6);
      bgColor = badgeColor!.withValues(alpha: 0.06);
    } else if (isHighlighted) {
      borderColor = theme.colorScheme.primary.withValues(alpha: 0.4);
    }

    return Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(AppSizes.cardRadius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.spacing12,
            vertical: AppSizes.spacing12,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSizes.cardRadius),
            border: Border.all(
              color: borderColor,
              width: isMatched ? 1.8 : 1.0,
            ),
          ),
          child: Row(
            children: [
              if (isMatched && badgeColor != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: badgeColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '#$matchedStemIndex',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: AppSizes.spacing8),
              ],
              Expanded(
                child: MixedLatexText(
                  text: option.text,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: isMatched ? FontWeight.w600 : FontWeight.w500,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
              if (isValidationVisible && isMatched)
                Icon(
                  isCorrect ? Icons.check_circle : Icons.cancel,
                  color: isCorrect ? AppColors.success : AppColors.error,
                  size: 20,
                )
              else if (isMatched)
                IconButton(
                  icon: const Icon(Icons.close, size: 16),
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  color: theme.colorScheme.onSurfaceVariant,
                  onPressed: onTap,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
