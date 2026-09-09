import 'package:flutter/material.dart';

import 'package:dgt_app/core/constants/app_sizes.dart';
import 'package:dgt_app/core/widgets/mixed_latex_text.dart';
import 'package:dgt_app/features/home/domain/models/quiz_models.dart';
import 'package:dgt_app/localization/app_localizations.dart';
import 'package:dgt_app/theme/app_colors.dart';
import 'quiz_button.dart';

class DragAndDropQuizWidget extends StatefulWidget {
  const DragAndDropQuizWidget({
    required this.number,
    required this.data,
    this.initialDroppedValue,
    this.onDroppedChanged,
    this.onSubmit,
    this.isSubmitting = false,
    this.isSubmitted = false,
    this.showValidation = false,
    super.key,
  });

  final int number;
  final DragAndDropQuizData data;
  final String? initialDroppedValue;
  final ValueChanged<String?>? onDroppedChanged;
  final ValueChanged<String>? onSubmit;
  final bool isSubmitting;
  final bool isSubmitted;
  final bool showValidation;

  @override
  State<DragAndDropQuizWidget> createState() => _DragAndDropQuizWidgetState();
}

class _DragAndDropQuizWidgetState extends State<DragAndDropQuizWidget> {
  String? _droppedItem;

  @override
  void initState() {
    super.initState();
    _droppedItem = widget.initialDroppedValue;
  }

  @override
  void didUpdateWidget(covariant DragAndDropQuizWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialDroppedValue != oldWidget.initialDroppedValue) {
      _droppedItem = widget.initialDroppedValue;
    }
  }

  void _onItemDropped(String item) {
    if (widget.isSubmitted || widget.isSubmitting) return;
    setState(() {
      _droppedItem = item;
    });
    widget.onDroppedChanged?.call(item);
  }

  void _onRemoveDropped() {
    if (widget.isSubmitted || widget.isSubmitting) return;
    setState(() {
      _droppedItem = null;
    });
    widget.onDroppedChanged?.call(null);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final questionPrefix = context.l10n.text('questionPrefix');
    final isValidation = widget.showValidation || widget.isSubmitted;
    final isCorrect = _droppedItem != null && widget.data.isCorrect(_droppedItem!);

    final promptText = widget.data.prompt.isNotEmpty
        ? widget.data.prompt
        : 'Drag or tap the correct answer into the drop zone:';

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
                text: promptText,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.spacing8),
        Text(
          'Target: ${_formatDroppableId(widget.data.droppableId)}',
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppSizes.spacing16),

        // Droppable Target Slot
        _buildDroppableZone(theme, isValidation, isCorrect),

        const SizedBox(height: AppSizes.spacing20),

        // Draggables Pool
        Text(
          'Available Choices',
          style: theme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: theme.colorScheme.secondary,
          ),
        ),
        const SizedBox(height: AppSizes.spacing8),
        _buildDraggablesPool(theme),

        const SizedBox(height: AppSizes.spacing16),

        if (widget.onSubmit != null)
          Align(
            alignment: Alignment.centerRight,
            child: QuizButton(
              onPressed: widget.isSubmitting || _droppedItem == null
                  ? null
                  : () => widget.onSubmit?.call(_droppedItem!),
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

  Widget _buildDroppableZone(ThemeData theme, bool isValidation, bool isCorrect) {
    return DragTarget<String>(
      onWillAcceptWithDetails: (details) =>
          !widget.isSubmitted && !widget.isSubmitting,
      onAcceptWithDetails: (details) => _onItemDropped(details.data),
      builder: (context, candidateData, rejectedData) {
        final isHovering = candidateData.isNotEmpty;
        final hasItem = _droppedItem != null;

        Color borderColor = theme.colorScheme.outlineVariant;
        Color bgColor = theme.colorScheme.surfaceContainerLow;

        if (isValidation && hasItem) {
          borderColor = isCorrect ? AppColors.success : AppColors.error;
          bgColor = (isCorrect ? AppColors.success : AppColors.error).withValues(
            alpha: 0.08,
          );
        } else if (isHovering) {
          borderColor = theme.colorScheme.primary;
          bgColor = theme.colorScheme.primary.withValues(alpha: 0.12);
        } else if (hasItem) {
          borderColor = theme.colorScheme.primary;
          bgColor = theme.colorScheme.primary.withValues(alpha: 0.06);
        }

        return Container(
          height: 90,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(AppSizes.cardRadius),
            border: Border.all(
              color: borderColor,
              width: isHovering || (isValidation && hasItem) ? 2.0 : 1.5,
            ),
          ),
          child: Center(
            child: hasItem
                ? _buildDroppedItemChip(theme, isValidation, isCorrect)
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isHovering
                            ? Icons.download
                            : Icons.drag_indicator,
                        color: isHovering
                            ? theme.colorScheme.primary
                            : theme.colorScheme.outline,
                        size: 20,
                      ),
                      const SizedBox(width: AppSizes.spacing8),
                      Text(
                        isHovering
                            ? 'Release to drop here'
                            : 'Drop answer here (or tap a choice below)',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: isHovering
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurfaceVariant,
                          fontWeight: isHovering
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }

  Widget _buildDroppedItemChip(ThemeData theme, bool isValidation, bool isCorrect) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.spacing16,
        vertical: AppSizes.spacing8,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isValidation
              ? (isCorrect ? AppColors.success : AppColors.error)
              : theme.colorScheme.primary,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          MixedLatexText(
            text: _droppedItem!,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(width: AppSizes.spacing12),
          if (isValidation)
            Icon(
              isCorrect ? Icons.check_circle : Icons.cancel,
              color: isCorrect ? AppColors.success : AppColors.error,
              size: 20,
            )
          else if (!widget.isSubmitted)
            InkWell(
              onTap: _onRemoveDropped,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(2.0),
                child: Icon(
                  Icons.close,
                  size: 18,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDraggablesPool(ThemeData theme) {
    return Wrap(
      spacing: AppSizes.spacing12,
      runSpacing: AppSizes.spacing12,
      children: [
        for (final item in widget.data.draggables)
          _buildDraggableItem(theme, item),
      ],
    );
  }

  Widget _buildDraggableItem(ThemeData theme, String item) {
    final isAlreadyPlaced = _droppedItem == item;
    final isInteractive = !widget.isSubmitted && !widget.isSubmitting;

    final chipWidget = Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.spacing16,
        vertical: AppSizes.spacing8,
      ),
      decoration: BoxDecoration(
        color: isAlreadyPlaced
            ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)
            : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        border: Border.all(
          color: isAlreadyPlaced
              ? theme.colorScheme.outlineVariant.withValues(alpha: 0.4)
              : theme.colorScheme.outlineVariant,
          width: 1.2,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.drag_indicator,
            size: 16,
            color: isAlreadyPlaced
                ? theme.colorScheme.outline.withValues(alpha: 0.4)
                : theme.colorScheme.outline,
          ),
          const SizedBox(width: AppSizes.spacing8),
          MixedLatexText(
            text: item,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: isAlreadyPlaced
                  ? theme.colorScheme.onSurface.withValues(alpha: 0.35)
                  : theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );

    if (!isInteractive || isAlreadyPlaced) {
      return chipWidget;
    }

    // Wrap with Draggable and InkWell for tap-to-place fallback
    return Draggable<String>(
      data: item,
      feedback: Material(
        elevation: 6,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.spacing20,
            vertical: AppSizes.spacing12,
          ),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(AppSizes.cardRadius),
            border: Border.all(color: theme.colorScheme.primary, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: MixedLatexText(
            text: item,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: theme.colorScheme.primary,
            ),
          ),
        ),
      ),
      childWhenDragging: Opacity(opacity: 0.3, child: chipWidget),
      child: InkWell(
        onTap: () => _onItemDropped(item),
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        child: chipWidget,
      ),
    );
  }

  String _formatDroppableId(String id) {
    if (id.isEmpty) return 'Default Slot';
    return id.replaceAll('-', ' ').replaceAll('_', ' ').toUpperCase();
  }
}
