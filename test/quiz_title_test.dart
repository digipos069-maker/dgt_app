import 'package:dgt_app/features/home/domain/models/quiz_models.dart';
import 'package:dgt_app/features/home/presentation/widgets/quiz/quiz_question_dispatcher.dart';
import 'package:dgt_app/localization/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Matching and drag-and-drop quizzes must show the question's own title
/// (the API's `question` field), not only the generic fallback.
void main() {
  Widget app(Widget child) {
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

  bool hasText(WidgetTester tester, String text) {
    return find
        .byWidgetPredicate(
          (w) => w is Text && w.textSpan?.toPlainText().contains(text) == true,
        )
        .evaluate()
        .isNotEmpty;
  }

  Future<void> pumpQuestion(WidgetTester tester, Map<String, dynamic> json) {
    return tester.pumpWidget(
      app(
        QuizQuestionDispatcher(
          number: 1,
          question: QuizQuestionModel.fromJson(json),
          selectedAnswer: null,
          onAnswerChanged: null,
        ),
      ),
    );
  }

  testWidgets('matching quiz shows the API question as its title', (
    tester,
  ) async {
    await pumpQuestion(tester, {
      'id': 1,
      'question': 'Match each country with its capital',
      'type': 'MATCHING',
      'quizData': {
        'stems': [
          {'id': 's1', 'text': 'Cambodia'},
        ],
        'options': [
          {'id': 'o1', 'text': 'Phnom Penh'},
        ],
        'correctMatches': {'s1': 'o1'},
      },
    });
    await tester.pumpAndSettle();

    expect(hasText(tester, 'Match each country with its capital'), isTrue);
    expect(hasText(tester, 'Match each term with its definition.'), isFalse);
  });

  testWidgets('matching quiz shows the description under the title', (
    tester,
  ) async {
    await pumpQuestion(tester, {
      'id': 2,
      'question': 'Capitals of Asia',
      'type': 'MATCHING',
      'quizData': {
        'description': 'Tap a country, then its capital.',
        'stems': [
          {'id': 's1', 'text': 'Cambodia'},
        ],
        'options': [
          {'id': 'o1', 'text': 'Phnom Penh'},
        ],
        'correctMatches': {'s1': 'o1'},
      },
    });
    await tester.pumpAndSettle();

    expect(hasText(tester, 'Capitals of Asia'), isTrue);
    expect(hasText(tester, 'Tap a country, then its capital.'), isTrue);
  });

  testWidgets('drag-and-drop quiz shows the API question as its title', (
    tester,
  ) async {
    await pumpQuestion(tester, {
      'id': 3,
      'question': 'Which is the product of 2H₂ + O₂?',
      'type': 'DRAG_AND_DROP',
      'quizData': {
        'draggables': ['2H₂O', 'H₂'],
        'droppableId': 'product',
        'correct': '2H₂O',
      },
    });
    await tester.pumpAndSettle();

    expect(hasText(tester, 'Which is the product of 2H₂ + O₂?'), isTrue);
    expect(
      hasText(tester, 'Drag or tap the correct answer into the drop zone:'),
      isFalse,
    );
  });
}
