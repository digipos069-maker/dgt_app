/// Splits a tutor reply into display blocks (a tiny, chat-focused Markdown subset).
/// Pure Dart, so it is easy to unit test.
sealed class AiTutorBlock {
  const AiTutorBlock();
}

class AiTutorSpacerBlock extends AiTutorBlock {
  const AiTutorSpacerBlock();
}

class AiTutorHeadingBlock extends AiTutorBlock {
  const AiTutorHeadingBlock(this.text);
  final String text;
}

class AiTutorParagraphBlock extends AiTutorBlock {
  const AiTutorParagraphBlock(this.text);
  final String text;
}

class AiTutorListItemBlock extends AiTutorBlock {
  const AiTutorListItemBlock({required this.text, this.marker, this.indent = 0});
  final String text;

  /// "1." for numbered items, null for bullets.
  final String? marker;
  final int indent;
}

class AiTutorMathBlock extends AiTutorBlock {
  const AiTutorMathBlock(this.tex);
  final String tex;
}

abstract final class AiTutorRichTextParser {
  /// group(1) = $$display$$, group(2) = $inline$, group(3) = **bold**
  static final inlinePattern = RegExp(
    r'\$\$([\s\S]+?)\$\$|\$([^$\n]+?)\$|\*\*(.+?)\*\*',
  );

  static final _heading = RegExp(r'^#{1,6}\s+(.*)$');
  static final _bullet = RegExp(r'^(\s*)[-*•]\s+(.*)$');
  static final _numbered = RegExp(r'^(\s*)(\d{1,3})[.)]\s+(.*)$');
  static final _fence = RegExp(r'^```');

  /// [streaming] hides a trailing unfinished `**` or `$$` so half-written
  /// markup doesn't flash on screen while the reply is being typed.
  static List<AiTutorBlock> parse(String text, {bool streaming = false}) {
    final source = streaming ? _trimUnfinishedMarkup(text) : text;
    final lines = source.replaceAll('\r\n', '\n').split('\n');
    final blocks = <AiTutorBlock>[];

    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      final trimmed = line.trim();

      if (trimmed.isEmpty || _fence.hasMatch(trimmed)) {
        if (blocks.isNotEmpty && blocks.last is! AiTutorSpacerBlock) {
          blocks.add(const AiTutorSpacerBlock());
        }
        continue;
      }

      // Block math: $$ ... $$ possibly spanning several lines.
      if (trimmed.startsWith(r'$$')) {
        var buffer = trimmed;
        var j = i;
        while (_count(buffer, r'$$') < 2 && j + 1 < lines.length) {
          j++;
          buffer = '$buffer\n${lines[j].trim()}';
        }
        if (_count(buffer, r'$$') >= 2 && buffer.endsWith(r'$$') && buffer.length > 4) {
          final tex = buffer.substring(2, buffer.length - 2).trim();
          if (tex.isNotEmpty) {
            blocks.add(AiTutorMathBlock(tex));
            i = j;
            continue;
          }
        }
        // Not a clean standalone block: render as a paragraph (inline parser handles $$).
        blocks.add(AiTutorParagraphBlock(buffer));
        i = j;
        continue;
      }

      final heading = _heading.firstMatch(trimmed);
      if (heading != null) {
        blocks.add(AiTutorHeadingBlock(_stripWrappingBold(heading.group(1)!.trim())));
        continue;
      }

      final numbered = _numbered.firstMatch(line);
      if (numbered != null) {
        blocks.add(AiTutorListItemBlock(
          indent: _indentLevel(numbered.group(1)!),
          marker: '${numbered.group(2)}.',
          text: numbered.group(3)!.trim(),
        ));
        continue;
      }

      final bullet = _bullet.firstMatch(line);
      if (bullet != null) {
        blocks.add(AiTutorListItemBlock(
          indent: _indentLevel(bullet.group(1)!),
          text: bullet.group(2)!.trim(),
        ));
        continue;
      }

      blocks.add(AiTutorParagraphBlock(trimmed));
    }

    while (blocks.isNotEmpty && blocks.last is AiTutorSpacerBlock) {
      blocks.removeLast();
    }
    return blocks;
  }

  static String _trimUnfinishedMarkup(String text) {
    var result = text;
    if (_count(result, '**').isOdd) {
      final index = result.lastIndexOf('**');
      result = result.substring(0, index) + result.substring(index + 2);
    }
    if (_count(result, r'$$').isOdd) {
      // Show the unfinished equation once it is complete instead of raw LaTeX.
      result = result.substring(0, result.lastIndexOf(r'$$'));
    }
    return result;
  }

  static String _stripWrappingBold(String text) =>
      text.startsWith('**') && text.endsWith('**') && text.length > 4
          ? text.substring(2, text.length - 2)
          : text;

  static int _indentLevel(String leading) =>
      (leading.replaceAll('\t', '    ').length / 2).floor().clamp(0, 3);

  static int _count(String text, String token) {
    var count = 0;
    var index = text.indexOf(token);
    while (index != -1) {
      count++;
      index = text.indexOf(token, index + token.length);
    }
    return count;
  }
}
