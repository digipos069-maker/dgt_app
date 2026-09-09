import 'package:dgt_app/features/home/domain/models/quiz_models.dart';
import 'package:dgt_app/features/home/presentation/widgets/quiz/multiple_choice_quiz_widget.dart';
import 'package:dgt_app/features/home/presentation/widgets/quiz/quiz_button.dart';
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
  const sampleQuestion = QuizQuestionModel.multipleChoice(
    id: 'q1',
    questionKey: 'What is 2 + 2?',
    options: [
      QuizOptionModel(id: 'A', labelKey: '3'),
      QuizOptionModel(id: 'B', labelKey: '4'),
      QuizOptionModel(id: 'C', labelKey: '5'),
    ],
  );

  testWidgets('renders options and selects an option on tap', (tester) async {
    String? selected;

    await tester.pumpWidget(
      _buildTestApp(
        StatefulBuilder(
          builder: (context, setState) {
            return MultipleChoiceQuizWidget(
              number: 1,
              question: sampleQuestion,
              selectedOption: selected,
              onChanged: (val) {
                setState(() => selected = val);
              },
            );
          },
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.textContaining('3'), findsOneWidget);
    expect(find.textContaining('4'), findsOneWidget);
    expect(find.textContaining('5'), findsOneWidget);

    // Tap on option B (4)
    await tester.tap(find.textContaining('4'));
    await tester.pumpAndSettle();

    expect(selected, 'B');
  });

  testWidgets('verifies submit button uses #032EA1 brand color', (tester) async {
    await tester.pumpWidget(
      _buildTestApp(
        MultipleChoiceQuizWidget(
          number: 1,
          question: sampleQuestion,
          selectedOption: 'B',
          onChanged: (_) {},
          onSubmit: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    final quizButtonFinder = find.byType(QuizButton);
    expect(quizButtonFinder, findsOneWidget);

    final filledButtonFinder = find.byType(FilledButton);
    expect(filledButtonFinder, findsOneWidget);

    final filledButton = tester.widget<FilledButton>(filledButtonFinder);
    expect(
      filledButton.style?.backgroundColor?.resolve({}),
      const Color(0xFF032EA1),
    );
  });
}
