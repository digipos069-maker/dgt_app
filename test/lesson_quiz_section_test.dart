import 'package:dgt_app/features/home/domain/models/quiz_models.dart';
import 'package:dgt_app/features/home/presentation/widgets/quiz/lesson_quiz_section.dart';
import 'package:dgt_app/features/home/presentation/widgets/quiz/multiple_choice_quiz_widget.dart';
import 'package:dgt_app/features/home/presentation/widgets/quiz/matching_quiz_widget.dart';
import 'package:dgt_app/features/home/presentation/widgets/quiz/drag_and_drop_quiz_widget.dart';
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
  testWidgets('shows empty state when no questions exist', (tester) async {
    await tester.pumpWidget(
      _buildTestApp(
        LessonQuizSection(
          quizTitleKey: 'lessonQuizTitle',
          quizSubtitleKey: 'lessonQuizSubtitleLinear',
          questions: const [],
          answers: const {},
          onChanged: (_, _) {},
          submittingQuestions: const {},
          submittedQuestions: const {},
          answerFeedback: const {},
          onSubmit: (_) {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('There is no quiz for this lesson.'), findsOneWidget);
  });

  testWidgets('renders multiple choice, matching, and drag-and-drop questions', (tester) async {
    final questions = [
      const QuizQuestionModel.multipleChoice(
        id: 'q1',
        questionKey: 'Multiple Choice Question',
        options: [
          QuizOptionModel(id: 'opt1', labelKey: 'Option 1'),
        ],
      ),
      const QuizQuestionModel.matching(
        id: 'q2',
        matchingData: MatchingQuizData(
          stems: [QuizStem(id: 's1', text: 'Stem 1')],
          options: [MatchingOption(id: 'o1', text: 'Def 1')],
          description: 'Match Description',
          correctMatches: {'s1': 'o1'},
        ),
      ),
      const QuizQuestionModel.dragAndDrop(
        id: 'q3',
        dragAndDropData: DragAndDropQuizData(
          correct: '2H₂O',
          draggables: ['2H₂O', 'H₂'],
          droppableId: 'water-slot',
          prompt: 'Drag Prompt',
        ),
      ),
    ];

    await tester.pumpWidget(
      _buildTestApp(
        LessonQuizSection(
          quizTitleKey: 'lessonQuizTitle',
          quizSubtitleKey: 'lessonQuizSubtitleLinear',
          questions: questions,
          answers: const {},
          onChanged: (_, _) {},
          submittingQuestions: const {},
          submittedQuestions: const {},
          answerFeedback: const {},
          onSubmit: (_) {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(MultipleChoiceQuizWidget), findsOneWidget);
    expect(find.byType(MatchingQuizWidget), findsOneWidget);
    expect(find.byType(DragAndDropQuizWidget), findsOneWidget);
  });
}
