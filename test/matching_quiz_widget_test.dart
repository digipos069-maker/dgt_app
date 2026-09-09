import 'package:dgt_app/features/home/domain/models/quiz_models.dart';
import 'package:dgt_app/features/home/presentation/widgets/quiz/matching_quiz_widget.dart';
import 'package:dgt_app/localization/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _buildTestApp(Widget child) {
  return MaterialApp(
    locale: const Locale('en'),
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: const [
      AppLocalizations.delegate,
      DefaultWidgetsLocalizations.delegate,
      DefaultMaterialLocalizations.delegate,
    ],
    home: Scaffold(body: SingleChildScrollView(child: child)),
  );
}

void main() {
  const sampleMatchingData = MatchingQuizData(
    stems: [
      QuizStem(id: 's1', text: 'Term A'),
      QuizStem(id: 's2', text: 'Term B'),
    ],
    options: [
      MatchingOption(id: 'o1', text: 'Definition A'),
      MatchingOption(id: 'o2', text: 'Definition B'),
    ],
    description: 'Match terms with definitions',
    correctMatches: {
      's1': 'o1',
      's2': 'o2',
    },
  );

  testWidgets('pairs a stem with an option on tap and unpairs', (tester) async {
    Map<String, String> matches = {};

    await tester.pumpWidget(
      _buildTestApp(
        StatefulBuilder(
          builder: (context, setState) {
            return MatchingQuizWidget(
              number: 1,
              data: sampleMatchingData,
              initialMatches: matches,
              onMatchesChanged: (updated) {
                setState(() => matches = Map.from(updated));
              },
            );
          },
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.textContaining('Term A'), findsOneWidget);
    expect(find.textContaining('Term B'), findsOneWidget);
    expect(find.textContaining('Definition A'), findsOneWidget);
    expect(find.textContaining('Definition B'), findsOneWidget);

    // Tap Term A, then tap Definition A
    await tester.tap(find.textContaining('Term A'));
    await tester.pumpAndSettle();

    await tester.tap(find.textContaining('Definition A'));
    await tester.pumpAndSettle();

    expect(matches['s1'], 'o1');
    expect(find.text('#1'), findsOneWidget); // Option badge connected to stem 1

    // Unpair Term A
    await tester.tap(find.textContaining('Term A'));
    await tester.pumpAndSettle();

    expect(matches.containsKey('s1'), isFalse);
  });

  testWidgets('validates correct and incorrect matches when submitted', (tester) async {
    Map<String, String>? submittedMatches;

    await tester.pumpWidget(
      _buildTestApp(
        MatchingQuizWidget(
          number: 1,
          data: sampleMatchingData,
          initialMatches: const {'s1': 'o1', 's2': 'o2'},
          showValidation: true,
          onSubmit: (m) => submittedMatches = m,
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Both should display check icon for correct match
    expect(find.byIcon(Icons.check_circle), findsNWidgets(4)); // 2 stems + 2 options

    // Check button styling uses #032EA1
    final filledButton = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(
      filledButton.style?.backgroundColor?.resolve({}),
      const Color(0xFF032EA1),
    );

    // Tap submit button
    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();

    expect(submittedMatches, isNotNull);
    expect(submittedMatches!['s1'], 'o1');
    expect(submittedMatches!['s2'], 'o2');
  });
}
