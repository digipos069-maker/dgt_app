import 'package:dgt_app/features/home/domain/models/quiz_models.dart';
import 'package:dgt_app/features/home/presentation/widgets/quiz/drag_and_drop_quiz_widget.dart';
import 'package:dgt_app/features/home/presentation/widgets/quiz/matching_quiz_widget.dart';
import 'package:dgt_app/localization/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Guards against quiz text that stays in English when the app is in Khmer.
void main() {
  const quizKeys = [
    'quizMatchAllTerms',
    'quizPlaceAnswer',
    'matchingQuizTitle',
    'matchingQuizInstruction',
    'matchingQuizTerms',
    'matchingQuizDefinitions',
    'clear',
    'dragQuizDefaultPrompt',
    'dragQuizAvailableChoices',
    'dragQuizDropHere',
    'dragQuizReleaseToDrop',
    'quizExplanation',
    'quizCount',
    'quizProgress',
    'quizScore',
    'quizLoading',
    'quizLoadFailed',
  ];

  test('every quiz key has its own English and Khmer text', () {
    final english = AppLocalizations(const Locale('en'));
    final khmer = AppLocalizations(const Locale('km'));

    for (final key in quizKeys) {
      expect(english.text(key), isNot(key), reason: 'missing en: $key');
      expect(khmer.text(key), isNot(key), reason: 'missing km: $key');
      expect(
        khmer.text(key),
        isNot(english.text(key)),
        reason: 'km falls back to English: $key',
      );
    }
  });

  Widget khmerApp(Widget child) {
    return MaterialApp(
      locale: const Locale('km'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        DefaultWidgetsLocalizations.delegate,
        DefaultMaterialLocalizations.delegate,
      ],
      home: Scaffold(body: SingleChildScrollView(child: child)),
    );
  }

  testWidgets('drag-and-drop quiz shows Khmer labels', (tester) async {
    await tester.pumpWidget(
      khmerApp(
        const DragAndDropQuizWidget(
          number: 1,
          data: DragAndDropQuizData(
            correct: '2H₂O',
            draggables: ['2H₂O', 'H₂'],
            droppableId: 'water-molecule',
            prompt: '',
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final khmer = AppLocalizations(const Locale('km'));
    expect(find.text(khmer.text('dragQuizAvailableChoices')), findsOneWidget);
    expect(find.text(khmer.text('dragQuizDropHere')), findsOneWidget);
    expect(find.text('Available Choices'), findsNothing);
    expect(find.textContaining('Target:'), findsNothing);
  });

  testWidgets('matching quiz shows Khmer labels', (tester) async {
    await tester.pumpWidget(
      khmerApp(
        const MatchingQuizWidget(
          number: 1,
          data: MatchingQuizData(
            stems: [QuizStem(id: 's1', text: 'A')],
            options: [MatchingOption(id: 'o1', text: 'B')],
            description: 'Match',
            correctMatches: {'s1': 'o1'},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final khmer = AppLocalizations(const Locale('km'));
    expect(find.text(khmer.text('matchingQuizTerms')), findsOneWidget);
    expect(find.text(khmer.text('matchingQuizDefinitions')), findsOneWidget);
    expect(find.text(khmer.text('matchingQuizInstruction')), findsOneWidget);
    expect(find.text('Terms'), findsNothing);
    expect(find.text('clear'), findsNothing);
  });
}
