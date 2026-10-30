import 'package:flutter/material.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../localization/app_localizations.dart';

class AiTutorInputBar extends StatefulWidget {
  const AiTutorInputBar({
    required this.onSend,
    required this.onStop,
    required this.isSending,
    super.key,
  });

  final ValueChanged<String> onSend;

  /// "Stop generating" while the tutor is writing.
  final VoidCallback onStop;
  final bool isSending;

  /// Must match the API's AI_TUTOR_MAX_MESSAGE_LENGTH.
  static const maxLength = 2000;

  @override
  State<AiTutorInputBar> createState() => _AiTutorInputBarState();
}

class _AiTutorInputBarState extends State<AiTutorInputBar> {
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _canSend => !widget.isSending && _controller.text.trim().isNotEmpty;

  void _submit() {
    if (!_canSend) return;
    widget.onSend(_controller.text);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSizes.spacing12,
        AppSizes.spacing8,
        AppSizes.spacing8,
        AppSizes.spacing8,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.6)),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                minLines: 1,
                maxLines: 5,
                maxLength: AiTutorInputBar.maxLength,
                textInputAction: TextInputAction.newline,
                keyboardType: TextInputType.multiline,
                decoration: InputDecoration(
                  hintText: context.l10n.text('aiTutorInputHint'),
                  counterText: '',
                  isDense: true,
                  filled: true,
                  fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.spacing16,
                    vertical: AppSizes.spacing12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSizes.cardRadius),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSizes.spacing8),
            widget.isSending
                ? IconButton.filled(
                    onPressed: widget.onStop,
                    tooltip: context.l10n.text('aiTutorStop'),
                    icon: const Icon(Icons.stop_rounded),
                  )
                : IconButton.filled(
                    onPressed: _canSend ? _submit : null,
                    tooltip: context.l10n.text('aiTutorSend'),
                    icon: const Icon(Icons.arrow_upward_rounded),
                  ),
          ],
        ),
      ),
    );
  }
}
