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
}
