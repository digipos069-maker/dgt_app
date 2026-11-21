import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';

/// Renders content text that may contain LaTeX and basic HTML.
///
/// - LaTeX: `$inline$`, `\(inline\)`, `$$display$$` and `\[display\]` are
///   drawn with [Math.tex], as are editor formula tags such as
///   `<span class="ql-formula" data-value="x^2">` (Quill) or `data-latex`.
/// - HTML (from the content editor): paragraphs, line breaks, bold, italic,
///   underline, strike-through, lists, sub/superscript and `&...;` entities.
///   Any other tag is removed, so markup never shows up as text.
///
/// Text without HTML tags is rendered exactly as written.
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
          ..._MixedContentParser(text).parse(effectiveStyle),
        ],
      ),
      textAlign: textAlign,
    );
  }
}

/// Turns LaTeX + HTML content into spans. One instance parses one string.
class _MixedContentParser {
  _MixedContentParser(this.source)
    : _isHtml = _knownTagPattern.hasMatch(source);

  final String source;
  final bool _isHtml;

  final _runs = <_Run>[];
  final _lists = <_ListState>[];
  int _bold = 0;
  int _italic = 0;
  int _underline = 0;
  int _strike = 0;
  int _script = 0; // > 0 superscript, < 0 subscript

  // While > 0, we are inside an editor formula tag whose LaTeX was already
  // taken from its attribute, so its rendered inner content is skipped.
  int _skipDepth = 0;
  String? _skipTagName;

  List<InlineSpan> parse(TextStyle baseStyle) {
    final pattern = _isHtml ? _htmlTokenPattern : _latexPattern;
    var cursor = 0;

    for (final match in pattern.allMatches(source)) {
      final token = match.group(0)!;
      if (_skipDepth > 0) {
        if (!_isMathToken(token)) _trackSkippedTag(token);
        cursor = match.end;
        continue;
      }
      if (match.start > cursor) {
        _addText(source.substring(cursor, match.start));
      }
      if (_isMathToken(token)) {
        _addMath(token);
      } else {
        _handleTag(token);
      }
      cursor = match.end;
    }
    if (cursor < source.length && _skipDepth == 0) {
      _addText(source.substring(cursor));
    }

    if (_isHtml) _trimTrailingWhitespace();
    return [for (final run in _runs) run.toSpan(baseStyle)];
  }

  // ---- text and math -------------------------------------------------------

  void _addText(String raw) {
    var text = raw;
    if (_isHtml) {
      // In HTML, source line breaks and indentation are not meaningful.
      text = text.replaceAll(_htmlWhitespace, ' ');
      if (_atLineStart) text = text.trimLeft();
    }
    text = _decodeEntities(text).replaceAll('\u00A0', ' ');
    if (text.isEmpty) return;
    if (_script != 0) text = _toScript(text, superscript: _script > 0);
    _append(text);
  }

  static bool _isMathToken(String token) =>
      token.startsWith(r'$') ||
      token.startsWith(r'\(') ||
      token.startsWith(r'\[');

  void _addMath(String token) {
    final isDisplay = token.startsWith(r'$$') || token.startsWith(r'\[');
    final delimiterLength = token.startsWith(r'$') && !isDisplay ? 1 : 2;
    final expression = _decodeEntities(
      token.substring(delimiterLength, token.length - delimiterLength),
    ).trim();
    _addMathExpression(expression, source: token, isDisplay: isDisplay);
  }

  void _addMathExpression(
    String expression, {
    required String source,
    required bool isDisplay,
  }) {
    if (expression.isEmpty) {
      _append(source);
      return;
    }
    _runs.add(
      _Run.math(
        tex: expression,
        source: source,
        isDisplay: isDisplay,
        format: _currentFormat,
      ),
    );
  }

  void _append(String text) {
    final format = _currentFormat;
    final last = _runs.isEmpty ? null : _runs.last;
    if (last != null && last.tex == null && last.format == format) {
      last.text += text;
    } else {
      _runs.add(_Run.text(text, format));
    }
  }

  bool get _atLineStart {
    for (var i = _runs.length - 1; i >= 0; i--) {
      final run = _runs[i];
      if (run.tex != null) return false;
      if (run.text.isNotEmpty) return run.text.endsWith('\n');
    }
    return true;
  }

  // ---- tags ----------------------------------------------------------------

  void _handleTag(String token) {
    final match = _tagNamePattern.firstMatch(token);
    if (match == null) return; // comment
    final isClosing = match.group(1) == '/';
    final name = match.group(2)!.toLowerCase();
    final delta = isClosing ? -1 : 1;

    if (!isClosing) {
      final formula = _formulaAttributePattern.firstMatch(token);
      if (formula != null) {
        final expression = _decodeEntities(
          formula.group(1) ?? formula.group(2) ?? '',
        ).trim();
        if (expression.isNotEmpty) {
          _addMathExpression(expression, source: expression, isDisplay: false);
        }
        if (!token.endsWith('/>')) {
          _skipDepth = 1;
          _skipTagName = name;
        }
        return;
      }
    }

    switch (name) {
      case 'br':
        _append('\n');
      case 'p' || 'div' || 'blockquote' || 'section' || 'article' || 'hr':
        _blockBoundary();
      case 'h1' || 'h2' || 'h3' || 'h4' || 'h5' || 'h6':
        _blockBoundary();
        _bold = _clamp(_bold + delta);
      case 'tr' || 'table':
        _blockBoundary();
      case 'td' || 'th':
        if (isClosing) _append('  ');
      case 'ul' || 'ol':
        _blockBoundary();
        if (isClosing) {
          _popList();
        } else {
          _lists.add(_ListState(ordered: name == 'ol'));
        }
      case 'li':
        _blockBoundary();
        if (!isClosing) _append(_nextListMarker());
      case 'strong' || 'b':
        _bold = _clamp(_bold + delta);
      case 'em' || 'i':
        _italic = _clamp(_italic + delta);
      case 'u' || 'ins':
        _underline = _clamp(_underline + delta);
      case 's' || 'strike' || 'del':
        _strike = _clamp(_strike + delta);
      case 'sup':
        _script += delta;
      case 'sub':
        _script -= delta;
      default:
        // span, a, font, img, ... carry no formatting we support; drop them.
        break;
    }
  }

  void _trackSkippedTag(String token) {
    final match = _tagNamePattern.firstMatch(token);
    if (match == null || token.endsWith('/>')) return;
    if (match.group(2)!.toLowerCase() != _skipTagName) return;
    _skipDepth += match.group(1) == '/' ? -1 : 1;
    if (_skipDepth == 0) _skipTagName = null;
  }

  void _blockBoundary() {
    if (!_atLineStart) _append('\n');
  }

  void _popList() {
    if (_lists.isNotEmpty) _lists.removeLast();
  }

  String _nextListMarker() {
    if (_lists.isEmpty) return '• ';
    final indent = '   ' * (_lists.length - 1);
    final list = _lists.last;
    if (!list.ordered) return '$indent• ';
    list.count++;
    return '$indent${list.count}. ';
  }

  void _trimTrailingWhitespace() {
    while (_runs.isNotEmpty && _runs.last.tex == null) {
      final last = _runs.last;
      last.text = last.text.trimRight();
      if (last.text.isNotEmpty) break;
      _runs.removeLast();
    }
  }

  _Format get _currentFormat => _Format(
    bold: _bold > 0,
    italic: _italic > 0,
    underline: _underline > 0,
    strike: _strike > 0,
  );

  static int _clamp(int value) => value < 0 ? 0 : value;

  // ---- helpers -------------------------------------------------------------

  static String _decodeEntities(String text) {
    if (!text.contains('&')) return text;
    return text.replaceAllMapped(_entityPattern, (match) {
      final entity = match.group(1)!;
      if (entity.startsWith('#')) {
        final isHex = entity.length > 1 && (entity[1] == 'x' || entity[1] == 'X');
        final code = int.tryParse(
          entity.substring(isHex ? 2 : 1),
          radix: isHex ? 16 : 10,
        );
        if (code == null || code <= 0 || code > 0x10FFFF) return match.group(0)!;
        if (code == 0xA0) return ' ';
        return String.fromCharCode(code);
      }
      return _namedEntities[entity] ?? match.group(0)!;
    });
  }

  /// Uses Unicode super/subscript characters (x², H₂O) when every character
  /// has one; otherwise keeps the text as it is.
  static String _toScript(String text, {required bool superscript}) {
    final map = superscript ? _superscripts : _subscripts;
    final buffer = StringBuffer();
    for (final rune in text.runes) {
      final mapped = map[String.fromCharCode(rune)];
      if (mapped == null) return text;
      buffer.write(mapped);
    }
    return buffer.toString();
  }

  static final _latexPattern = RegExp(
    r'\$\$[\s\S]*?\$\$|\\\[[\s\S]*?\\\]|\\\([\s\S]*?\\\)|\$[^$\r\n]*?\$',
  );

  /// LaTeX first, so `$a<b$` is treated as math and not as a tag.
  static final _htmlTokenPattern = RegExp(
    r'\$\$[\s\S]*?\$\$|\\\[[\s\S]*?\\\]|\\\([\s\S]*?\\\)|\$[^$\r\n]*?\$|<!--[\s\S]*?-->|<\/?[a-zA-Z][a-zA-Z0-9]*(?:\s[^<>]*)?\/?>',
  );

  /// The text only counts as HTML if it has one of these tags, so plain text
  /// such as "x < 5 and y > 2" is never touched.
  static final _knownTagPattern = RegExp(
    r'<\/?(?:p|br|div|span|strong|b|em|i|u|ins|s|strike|del|ul|ol|li|h[1-6]|sup|sub|blockquote|a|font|table|tr|td|th|img|hr|section|article)(?:\s[^<>]*)?\/?>',
    caseSensitive: false,
  );

  static final _tagNamePattern = RegExp(r'^<(\/?)([a-zA-Z][a-zA-Z0-9]*)');

  /// Editor formula tags keep the LaTeX in an attribute, e.g. Quill's
  /// `<span class="ql-formula" data-value="x^2">` or `data-latex="x^2"`.
  static final _formulaAttributePattern = RegExp(
    r'''\sdata-(?:value|latex|formula|tex)\s*=\s*(?:"([^"]*)"|'([^']*)')''',
  );
  static final _htmlWhitespace = RegExp(r'[ \t\r\n]+');
  static final _entityPattern = RegExp(r'&(#[xX][0-9a-fA-F]+|#[0-9]+|[a-zA-Z]+);');

  static const _namedEntities = {
    // Editors often put &nbsp; between every word; a real non-breaking space
    // would turn the whole sentence into one line that cannot wrap.
    'nbsp': ' ',
    'amp': '&',
    'lt': '<',
    'gt': '>',
    'quot': '"',
    'apos': "'",
    'ndash': '–',
    'mdash': '—',
    'hellip': '…',
    'lsquo': '‘',
    'rsquo': '’',
    'ldquo': '“',
    'rdquo': '”',
    'laquo': '«',
    'raquo': '»',
    'bull': '•',
    'middot': '·',
    'times': '×',
    'divide': '÷',
    'minus': '−',
    'plusmn': '±',
    'le': '≤',
    'ge': '≥',
    'ne': '≠',
    'deg': '°',
    'pi': 'π',
    'radic': '√',
    'infin': '∞',
  };

  static const _superscripts = {
    '0': '⁰', '1': '¹', '2': '²', '3': '³', '4': '⁴', '5': '⁵', '6': '⁶',
    '7': '⁷', '8': '⁸', '9': '⁹', '+': '⁺', '-': '⁻', '−': '⁻', '=': '⁼',
    '(': '⁽', ')': '⁾', 'n': 'ⁿ', 'i': 'ⁱ', 'x': 'ˣ', ' ': ' ',
  };

  static const _subscripts = {
    '0': '₀', '1': '₁', '2': '₂', '3': '₃', '4': '₄', '5': '₅', '6': '₆',
    '7': '₇', '8': '₈', '9': '₉', '+': '₊', '-': '₋', '−': '₋', '=': '₌',
    '(': '₍', ')': '₎', 'n': 'ₙ', 'x': 'ₓ', ' ': ' ',
  };
}

class _ListState {
  _ListState({required this.ordered});

  final bool ordered;
  int count = 0;
}

class _Format {
  const _Format({
    this.bold = false,
    this.italic = false,
    this.underline = false,
    this.strike = false,
  });

  final bool bold;
  final bool italic;
  final bool underline;
  final bool strike;

  TextStyle? toStyle() {
    if (!bold && !italic && !underline && !strike) return null;
    return TextStyle(
      fontWeight: bold ? FontWeight.bold : null,
      fontStyle: italic ? FontStyle.italic : null,
      decoration: underline || strike
          ? TextDecoration.combine([
              if (underline) TextDecoration.underline,
              if (strike) TextDecoration.lineThrough,
            ])
          : null,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is _Format &&
      other.bold == bold &&
      other.italic == italic &&
      other.underline == underline &&
      other.strike == strike;

  @override
  int get hashCode => Object.hash(bold, italic, underline, strike);
}

class _Run {
  _Run.text(this.text, this.format) : tex = null, source = null, isDisplay = false;

  _Run.math({
    required String this.tex,
    required String this.source,
    required this.isDisplay,
    required this.format,
  }) : text = '';

  String text;
  final String? tex;
  final String? source;
  final bool isDisplay;
  final _Format format;

  InlineSpan toSpan(TextStyle baseStyle) {
    final style = format.toStyle();
    final math = tex;
    if (math == null) return TextSpan(text: text, style: style);

    final mathStyle = style == null ? baseStyle : baseStyle.merge(style);
    return WidgetSpan(
      alignment: PlaceholderAlignment.middle,
      child: _ScrollableMath(
        child: Math.tex(
          math,
          mathStyle: isDisplay ? MathStyle.display : MathStyle.text,
          textStyle: mathStyle,
          onErrorFallback: (error) {
            developer.log(
              'Could not render LaTeX "$math": $error',
              name: 'dgt.latex',
            );
            return Text(source!, style: mathStyle);
          },
        ),
      ),
    );
  }
}

/// A formula is one unbreakable block, so a long equation cannot wrap like
/// text. When it is wider than the space available, let it scroll sideways
/// instead of spilling outside its card.
class _ScrollableMath extends StatelessWidget {
  const _ScrollableMath({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // e.g. a drag-and-drop chip being dragged has no width limit.
        if (!constraints.hasBoundedWidth) return child;
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: child,
        );
      },
    );
  }
}
