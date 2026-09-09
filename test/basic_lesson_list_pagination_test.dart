import 'package:dgt_app/features/auth/application/auth_controller.dart';
import 'package:dgt_app/features/auth/domain/models/user_model.dart';
import 'package:dgt_app/features/home/application/basic_course_controller.dart';
import 'package:dgt_app/features/home/data/basic_course_repository.dart';
import 'package:dgt_app/features/home/domain/models/basic_course_model.dart';
import 'package:dgt_app/features/home/domain/models/basic_lesson_model.dart';
import 'package:dgt_app/features/home/presentation/widgets/basic_lesson_list_body.dart';
import 'package:dgt_app/localization/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeBasicCourseRepository extends Fake
    implements BasicCourseRepository {
  int fetchCallCount = 0;
  final List<int> requestedPages = [];
  final List<int> requestedLimits = [];

  @override
  Future<BasicLessonBundle> fetchBasicLessons({
    required String token,
    required String courseId,
    required String languageCode,
    int page = 1,
    int limit = 10,
    int? offset,
  }) async {
    fetchCallCount++;
    requestedPages.add(page);
    requestedLimits.add(limit);

    final start = offset ?? ((page - 1) * limit);
    final totalAvailable = 15;
    final items = <BasicLessonModel>[];
    for (var i = 0; i < limit; i++) {
      final index = start + i + 1;
      if (index > totalAvailable) break;
      items.add(
        BasicLessonModel(
          id: 'basic-$index',
          courseId: courseId,
          name: 'Basic Lesson $index',
          thumbnail: '',
          description: 'Description for basic lesson $index',
          durationLabel: '10:00',
        ),
      );
    }

    return BasicLessonBundle(
      course: const BasicCourseModel(
        id: 'mathematics',
        name: 'Mathematics',
        thumbnail: '',
        description: 'Math basic course',
      ),
      lessons: items,
      page: page,
      hasMore: (start + items.length) < totalAvailable,
    );
  }
}

void main() {
  testWidgets('initial load shows 10 basic lessons and loads 5 more on scroll', (
    tester,
  ) async {
    final fakeRepo = _FakeBasicCourseRepository();
    const fakeUser = UserModel(
      id: '1',
      username: 'Tester',
      email: 'tester@test.com',
      token: 'fake-jwt-token',
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authControllerProvider.overrideWith(
            () => _FakeAuthController(fakeUser),
          ),
          basicCourseRepositoryProvider.overrideWithValue(fakeRepo),
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
            body: BasicLessonListBody(courseId: 'mathematics'),
          ),
        ),
      ),
    );

    // Initial load
    await tester.pumpAndSettle();

    expect(fakeRepo.fetchCallCount, 1);
    expect(fakeRepo.requestedPages.first, 1);
    expect(fakeRepo.requestedLimits.first, 10);
    expect(find.text('Basic Lesson 1'), findsOneWidget);

    final scrollableFinder = find.byType(Scrollable);
    expect(scrollableFinder, findsWidgets);

    // Scroll to item 10
    await tester.scrollUntilVisible(
      find.text('Basic Lesson 10'),
      100.0,
      scrollable: scrollableFinder.first,
    );
    expect(find.text('Basic Lesson 10'), findsOneWidget);

    // Scroll to bottom to trigger load more
    await tester.drag(scrollableFinder.first, const Offset(0, -400));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();

    // Verify next page requested limit 5
    expect(fakeRepo.fetchCallCount, 2);
    expect(fakeRepo.requestedLimits[1], 5);

    // Scroll to item 15
    await tester.scrollUntilVisible(
      find.text('Basic Lesson 15'),
      100.0,
      scrollable: scrollableFinder.first,
    );
    expect(find.text('Basic Lesson 15'), findsOneWidget);
  });
}

class _FakeAuthController extends AuthController {
  _FakeAuthController(this._user);
  final UserModel _user;

  @override
  Future<UserModel?> build() async => _user;
}
