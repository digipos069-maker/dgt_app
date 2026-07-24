import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';

class MixedLatexText extends StatelessWidget {
  const MixedLatexText({
    required this.text,
    this.style,
    this.prefix,
    this.prefixStyle,
    this.textAlign = TextAlign.start,
    super.key,
  });

  final String text;
  final TextStyle? style;
  final String? prefix;
  final TextStyle? prefixStyle;
  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) {
    final effectiveStyle = style ?? DefaultTextStyle.of(context).style;

    return Text.rich(
      TextSpan(
        style: effectiveStyle,
        children: [
          if (prefix?.isNotEmpty == true)
            TextSpan(text: prefix, style: prefixStyle),
          ..._buildSegments(effectiveStyle),
        ],
      ),
      textAlign: textAlign,
    );
  }

  List<InlineSpan> _buildSegments(TextStyle effectiveStyle) {
    final spans = <InlineSpan>[];
    var cursor = 0;

    for (final match in _latexPattern.allMatches(text)) {
      if (match.start > cursor) {
        spans.add(TextSpan(text: text.substring(cursor, match.start)));
      }

      final source = match.group(0)!;
      final isDisplayMath = source.startsWith(r'$$');
      final delimiterLength = isDisplayMath ? 2 : 1;
      final expression = source
          .substring(delimiterLength, source.length - delimiterLength)
          .trim();

      if (expression.isEmpty) {
        spans.add(TextSpan(text: source));
      } else {
        spans.add(
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: Math.tex(
              expression,
              mathStyle: isDisplayMath ? MathStyle.display : MathStyle.text,
              textStyle: effectiveStyle,
              onErrorFallback: (_) => Text(source, style: effectiveStyle),
            ),
          ),
        );
      }
      cursor = match.end;
    }

    if (cursor < text.length) {
      spans.add(TextSpan(text: text.substring(cursor)));
    }
    return spans;
  }

  static final _latexPattern = RegExp(r'\$\$[\s\S]*?\$\$|\$[^$\r\n]*?\$');
}
