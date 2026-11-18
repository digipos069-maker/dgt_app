import 'package:dgt_app/core/widgets/mixed_latex_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders inline and display LaTeX inside normal text', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: MixedLatexText(
            prefix: 'Question 1. ',
            text: r'Find $\sqrt{-9}$ and compare it with $$3i$$.',
          ),
        ),
      ),
    );

    expect(find.byType(Math), findsNWidgets(2));
    expect(tester.takeException(), isNull);
  });

  testWidgets('keeps malformed delimiters as readable text', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: MixedLatexText(text: r'Value is $\sqrt{-9}')),
      ),
    );

    expect(find.byType(Math), findsNothing);
    expect(find.textContaining(r'$\sqrt{-9}'), findsOneWidget);
  });

  String plainText(WidgetTester tester) {
    final text = tester.widget<Text>(find.byType(Text).first);
    return text.textSpan!.toPlainText();
  }

  Future<void> pump(WidgetTester tester, String text) {
    return tester.pumpWidget(
      MaterialApp(home: Scaffold(body: MixedLatexText(text: text))),
    );
  }

  testWidgets('renders HTML from the editor without showing tags', (
    tester,
  ) async {
    await pump(
      tester,
      '<p>The answer is <strong>B</strong>.</p>\n<p>Because&nbsp;2 &gt; 1 &amp; 1 &lt; 2.</p>',
    );

    final text = plainText(tester);
    expect(text, 'The answer is B.\nBecause 2 > 1 & 1 < 2.');
    expect(text, isNot(contains('<')));
    expect(tester.takeException(), isNull);
  });

  testWidgets('makes <strong> text bold', (tester) async {
    await pump(tester, '<p>Look at <strong>this</strong></p>');

    final root = tester.widget<Text>(find.byType(Text).first).textSpan!;
    TextSpan? boldSpan;
    root.visitChildren((span) {
      if (span is TextSpan && span.text == 'this') boldSpan = span;
      return true;
    });
    expect(boldSpan?.style?.fontWeight, FontWeight.bold);
  });

  testWidgets('turns lists and line breaks into lines', (tester) async {
    await pump(
      tester,
      '<p>Steps:</p><ol><li>Add</li><li>Divide</li></ol><ul><li>Done<br>now</li></ul>',
    );

    expect(plainText(tester), 'Steps:\n1. Add\n2. Divide\n• Done\nnow');
  });

  testWidgets('keeps LaTeX working inside HTML', (tester) async {
    await pump(tester, r'<p>Since $x &lt; 3$, we get $$x^2$$.</p>');

    expect(find.byType(Math), findsNWidgets(2));
    expect(tester.takeException(), isNull);
  });

  testWidgets('removes unknown tags and uses Unicode superscripts', (
    tester,
  ) async {
    await pump(
      tester,
      '<p><span style="color:red">x<sup>2</sup></span> and H<sub>2</sub>O</p>',
    );

    expect(plainText(tester), 'x² and H₂O');
  });

  testWidgets('leaves plain text with < and > unchanged', (tester) async {
    await pump(tester, 'If x < 5 and y > 2\nthen stop.');

    expect(plainText(tester), 'If x < 5 and y > 2\nthen stop.');
  });
}
