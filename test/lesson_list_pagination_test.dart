import 'package:dgt_app/features/home/application/lesson_controller.dart';
import 'package:dgt_app/features/home/domain/models/lesson_model.dart';
import 'package:dgt_app/features/home/presentation/widgets/lesson_list_body.dart';
import 'package:dgt_app/localization/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('initial load shows 10 items and loads more on scroll', (
    tester,
  ) async {
    final mockLessons = List.generate(
      25,
      (index) => LessonModel(
        courseId: 'algebra',
        id: 'lesson-$index',
        title: 'Lesson #$index',
        titleKey: 'Lesson $index',
        type: LessonType.reading,
        durationMinutes: 10,
        isCompleted: false,
      ),
    );

    final mockBundle = CourseLessonBundle(
      courseId: 'algebra',
      appBarTitleKey: 'Algebra',
      titleKey: 'chapterAlgebra',
      descriptionKey: 'lessonBundleAlgebraDescription',
      lessons: mockLessons,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          lessonBundleProvider('algebra').overrideWith(
            (ref) async => mockBundle,
          ),
        ],
        child: const MaterialApp(
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: [Locale('en'), Locale('km')],
          home: Scaffold(
            body: LessonListBody(courseId: 'algebra'),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify initial visible item: Lesson #0 is present
    expect(find.text('Lesson #0'), findsOneWidget);

    final scrollableFinder = find.byType(Scrollable);
    expect(scrollableFinder, findsWidgets);

    // Scroll to item 9 (end of initial batch)
    await tester.scrollUntilVisible(
      find.text('Lesson #9'),
      100,
      scrollable: scrollableFinder.first,
    );
    expect(find.text('Lesson #9'), findsOneWidget);

    // Scroll near the bottom to trigger auto load more
    await tester.drag(scrollableFinder.first, const Offset(0, -300));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();

    // Now item 15 in the second batch can be scrolled to
    await tester.scrollUntilVisible(
      find.text('Lesson #15'),
      100,
      scrollable: scrollableFinder.first,
    );
    expect(find.text('Lesson #15'), findsOneWidget);
  });
}
