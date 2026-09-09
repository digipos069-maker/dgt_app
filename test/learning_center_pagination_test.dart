import 'package:dgt_app/features/home/application/learning_lesson_controller.dart';
import 'package:dgt_app/features/home/data/learning_lesson_repository.dart';
import 'package:dgt_app/features/home/domain/models/learning_lesson_model.dart';
import 'package:dgt_app/features/home/presentation/widgets/learning_center_body.dart';
import 'package:dgt_app/localization/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeLearningLessonRepository implements LearningLessonRepository {
  FakeLearningLessonRepository({required this.totalLessons});

  final int totalLessons;
  final List<Map<String, int>> fetchCalls = [];

  @override
  Future<LearningLessonBundle> fetchLessons({
    required int gradeId,
    required int subjectId,
    int page = 1,
    int limit = 10,
  }) async {
    fetchCalls.add({'page': page, 'limit': limit});
    final startIndex = (page - 1) * limit;
    final endIndex = (startIndex + limit).clamp(0, totalLessons);

    final lessons = <LearningLessonModel>[];
    for (var i = startIndex; i < endIndex; i++) {
      lessons.add(
        LearningLessonModel(
          id: 'lesson-$i',
          title: 'Lesson #$i',
          description: 'Description #$i',
          thumbnail: '',
          subjectId: subjectId,
          gradeId: gradeId,
          durationMinutes: 15,
          rating: 4.8,
          learnerCount: 100,
          isLocked: false,
        ),
      );
    }

    final hasMore = endIndex < totalLessons;
    return LearningLessonBundle(
      lessons: lessons,
      page: page,
      hasMore: hasMore,
    );
  }
}

void main() {
  testWidgets('loading spinner only shows when fetching more and hides on end of data', (tester) async {
    final repository = FakeLearningLessonRepository(totalLessons: 15);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          learningLessonRepositoryProvider.overrideWithValue(repository),
        ],
        child: MaterialApp(
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          home: Scaffold(
            body: LearningCenterBody(
              gradeId: 1,
              gradeNumber: 1,
              initialSubjectId: 1,
              onBack: () {},
            ),
          ),
        ),
      ),
    );

    // Settle initial load
    await tester.pumpAndSettle();

    // Verify initial 10 lessons are rendered
    expect(find.text('Lesson #0'), findsOneWidget);

    // Initial load has hasMore = true, BUT isFetchingMore = false.
    // Ensure loading spinner is NOT shown while idle.
    expect(find.byType(CircularProgressIndicator), findsNothing);

    // Scroll to the end of the scroll view
    final scrollable = find.byType(Scrollable).first;
    await tester.scrollUntilVisible(find.text('Lesson #9'), 300, scrollable: scrollable);
    
    // Drag further to trigger loadMore threshold
    await tester.drag(scrollable, const Offset(0, -500));
    await tester.pump();
    await tester.pumpAndSettle();

    // Now second batch can be scrolled to
    await tester.scrollUntilVisible(find.text('Lesson #14'), 300, scrollable: scrollable);
    expect(find.text('Lesson #14'), findsOneWidget);

    // Now all 15 lessons are loaded, hasMore is false, isFetchingMore is false.
    // Verify loading spinner is STILL hidden (not stuck).
    expect(find.byType(CircularProgressIndicator), findsNothing);

    expect(repository.fetchCalls.length, 2);
    expect(repository.fetchCalls[0], {'page': 1, 'limit': 10});
    expect(repository.fetchCalls[1], {'page': 2, 'limit': 10});
  });
}
