import 'package:dgt_app/features/home/domain/models/quiz_models.dart';
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
  const sampleData = DragAndDropQuizData(
    correct: '2H₂O',
    draggables: ['2H₂O', 'H₂', 'O₂'],
    droppableId: 'water-molecule',
    prompt: 'Place the balanced water product',
  );

  testWidgets('renders droppable target and draggables pool', (tester) async {
    await tester.pumpWidget(
      _buildTestApp(
        const DragAndDropQuizWidget(
          number: 1,
          data: sampleData,
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Target: WATER MOLECULE'), findsOneWidget);
    expect(find.byWidgetPredicate((w) => w is Text && w.textSpan?.toPlainText() == '2H₂O'), findsOneWidget);
    expect(find.byWidgetPredicate((w) => w is Text && w.textSpan?.toPlainText() == 'H₂'), findsOneWidget);
    expect(find.byWidgetPredicate((w) => w is Text && w.textSpan?.toPlainText() == 'O₂'), findsOneWidget);
    expect(find.text('Drop answer here (or tap a choice below)'), findsOneWidget);
  });

  testWidgets('places item via tap and clears via close button', (tester) async {
    String? dropped;

    await tester.pumpWidget(
      _buildTestApp(
        StatefulBuilder(
          builder: (context, setState) {
            return DragAndDropQuizWidget(
              number: 1,
              data: sampleData,
              initialDroppedValue: dropped,
              onDroppedChanged: (val) {
                setState(() => dropped = val);
              },
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Tap on '2H₂O'
    await tester.tap(find.textContaining('2H₂O'));
    await tester.pumpAndSettle();

    expect(dropped, '2H₂O');

    // Remove icon should be present
    final closeButtonFinder = find.byIcon(Icons.close);
    expect(closeButtonFinder, findsOneWidget);

    await tester.tap(closeButtonFinder);
    await tester.pumpAndSettle();

    expect(dropped, isNull);
  });

  testWidgets('verifies submit button uses #032EA1 and validates answer', (tester) async {
    String? submitted;

    await tester.pumpWidget(
      _buildTestApp(
        DragAndDropQuizWidget(
          number: 1,
          data: sampleData,
          initialDroppedValue: '2H₂O',
          showValidation: true,
          onSubmit: (val) => submitted = val,
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Correct icon check
    expect(find.byIcon(Icons.check_circle), findsOneWidget);

    // Check button styling uses #032EA1
    final filledButton = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(
      filledButton.style?.backgroundColor?.resolve({}),
      const Color(0xFF032EA1),
    );

    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();

    expect(submitted, '2H₂O');
  });

  testWidgets('does not overflow on narrow screens (e.g. width 365)', (tester) async {
    tester.view.physicalSize = const Size(365.4, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      _buildTestApp(
        const DragAndDropQuizWidget(
          number: 1,
          data: sampleData,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Drop answer here (or tap a choice below)'), findsOneWidget);
  });
}
