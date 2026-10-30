import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';

import '../../../../core/constants/app_sizes.dart';
import 'ai_tutor_rich_text_parser.dart';

/// Renders a tutor reply ChatGPT-style: headings, bullet and numbered lists,
/// **bold**, inline $math$ and block $$math$$. Shows a blinking cursor while
/// the reply is still being written.
class AiTutorRichText extends StatelessWidget {
  const AiTutorRichText({
    required this.text,
    this.style,
    this.showCursor = false,
    super.key,
  });

  final String text;
  final TextStyle? style;
  final bool showCursor;

  @override
  Widget build(BuildContext context) {
    final baseStyle = style ?? DefaultTextStyle.of(context).style;
    final blocks = AiTutorRichTextParser.parse(text, streaming: showCursor);

    if (blocks.isEmpty) {
      return showCursor ? _BlinkingCursor(style: baseStyle) : const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < blocks.length; i++)
          _BlockView(
            block: blocks[i],
            style: baseStyle,
            showCursor: showCursor && i == blocks.length - 1,
          ),
      ],
    );
  }
}

class _BlockView extends StatelessWidget {
  const _BlockView({
    required this.block,
    required this.style,
    required this.showCursor,
  });

  final AiTutorBlock block;
  final TextStyle style;
  final bool showCursor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final block = this.block;

    switch (block) {
      case AiTutorSpacerBlock():
        return const SizedBox(height: AppSizes.spacing8);

      case AiTutorHeadingBlock(:final text):
        final headingStyle = style.copyWith(
          fontSize: (style.fontSize ?? 16) * 1.12,
          fontWeight: FontWeight.w800,
          color: theme.colorScheme.onSurface,
        );
        return Padding(
          padding: const EdgeInsets.only(top: AppSizes.spacing8, bottom: AppSizes.spacing4),
          child: _InlineText(text: text, style: headingStyle, showCursor: showCursor),
        );

      case AiTutorParagraphBlock(:final text):
        return _InlineText(text: text, style: style, showCursor: showCursor);

      case AiTutorListItemBlock(:final marker, :final text, :final indent):
        final isNumber = marker != null;
        return Padding(
          padding: EdgeInsets.only(left: indent * AppSizes.spacing16, top: 2, bottom: 2),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: isNumber ? 26 : 18,
                child: Text(
                  marker ?? '•',
                  style: style.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
              Expanded(
                child: _InlineText(text: text, style: style, showCursor: showCursor),
              ),
            ],
          ),
        );

      case AiTutorMathBlock(:final tex):
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSizes.spacing8),
          child: Center(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Math.tex(
                tex,
                mathStyle: MathStyle.display,
                textStyle: style,
                onErrorFallback: (_) => Text('\$\$$tex\$\$', style: style),
              ),
            ),
          ),
        );
    }
  }
}

/// A line of text with **bold**, $inline$ and $$display$$ math.
class _InlineText extends StatelessWidget {
  const _InlineText({
    required this.text,
    required this.style,
    required this.showCursor,
  });

  final String text;
  final TextStyle style;
  final bool showCursor;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        style: style,
        children: [
          ..._buildSpans(text, style),
          if (showCursor)
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: _BlinkingCursor(style: style),
            ),
        ],
      ),
    );
  }

  static List<InlineSpan> _buildSpans(String text, TextStyle style) {
    final spans = <InlineSpan>[];
    var cursor = 0;
    for (final match in AiTutorRichTextParser.inlinePattern.allMatches(text)) {
      if (match.start > cursor) {
        spans.add(TextSpan(text: text.substring(cursor, match.start)));
      }
      final displayMath = match.group(1);
      final inlineMath = match.group(2);
      final bold = match.group(3);
      if (bold != null) {
        final boldStyle = style.copyWith(fontWeight: FontWeight.w800);
        spans.add(TextSpan(style: boldStyle, children: _buildSpans(bold, boldStyle)));
      } else {
        final tex = (displayMath ?? inlineMath ?? '').trim();
        spans.add(
          tex.isEmpty
              ? TextSpan(text: match.group(0))
              : WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: Math.tex(
                    tex,
                    mathStyle: displayMath != null ? MathStyle.display : MathStyle.text,
                    textStyle: style,
                    onErrorFallback: (_) => Text(match.group(0)!, style: style),
                  ),
                ),
        );
      }
      cursor = match.end;
    }
    if (cursor < text.length) spans.add(TextSpan(text: text.substring(cursor)));
    return spans;
  }
}

class _BlinkingCursor extends StatefulWidget {
  const _BlinkingCursor({required this.style});

  final TextStyle style;

  @override
  State<_BlinkingCursor> createState() => _BlinkingCursorState();
}

class _BlinkingCursorState extends State<_BlinkingCursor>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = (widget.style.fontSize ?? 16) * 1.1;
    return FadeTransition(
      opacity: _controller,
      child: Container(
        margin: const EdgeInsets.only(left: 2),
        width: 8,
        height: height,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}
