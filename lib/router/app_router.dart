import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/presentation/pages/home_page.dart';
import '../features/auth/application/auth_controller.dart';
import '../features/auth/presentation/pages/login_page.dart';
import '../features/auth/presentation/pages/payment_history_page.dart';
import '../features/auth/presentation/pages/profile_page.dart';
import '../features/auth/presentation/pages/register_page.dart';
import '../features/home/presentation/pages/ai_tutor_page.dart';
import '../features/home/presentation/pages/basic_course_page.dart';
import '../features/home/presentation/pages/exam_test_detail_page.dart';
import '../features/home/presentation/pages/exam_test_list_page.dart';
import '../features/home/presentation/pages/my_study_page.dart';
import '../features/home/presentation/pages/basic_lesson_detail_page.dart';
import '../features/home/presentation/pages/basic_lesson_list_page.dart';
import '../features/home/presentation/pages/grade_list_page.dart';
import '../features/home/presentation/pages/learning_center_page.dart';
import '../features/home/presentation/pages/lesson_detail_page.dart';
import '../features/home/presentation/pages/lesson_list_page.dart';
import '../features/home/presentation/pages/resource_page.dart';
import '../features/home/presentation/pages/resource_years_page.dart';
import '../features/home/presentation/pages/resource_list_by_years_page.dart';
import '../features/home/presentation/pages/quiz_by_lesson_page.dart';

/// Routes that a signed-out user is allowed to open.
const _publicRoutePaths = {LoginPage.routePath, RegisterPage.routePath};

/// The app's single router.
///
/// It is created once and is not rebuilt when the user signs in or out, so the
/// navigation stack survives session changes. Auth changes are pushed into
/// [isSignedIn], which makes GoRouter re-run [GoRouter.redirect].
final appRouterProvider = Provider<GoRouter>((ref) {
  final isSignedIn = ValueNotifier<bool>(
    _isSignedIn(ref.read(authControllerProvider)),
  );
  ref.listen<bool>(
    authControllerProvider.select(_isSignedIn),
    (_, next) => isSignedIn.value = next,
  );

  final router = GoRouter(
    initialLocation: HomePage.routePath,
    refreshListenable: isSignedIn,
    redirect: (context, state) => authRedirect(
      isSignedIn: isSignedIn.value,
      location: state.matchedLocation,
    ),
    routes: [
      GoRoute(
        path: LoginPage.routePath,
        name: LoginPage.routeName,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: RegisterPage.routePath,
        name: RegisterPage.routeName,
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: HomePage.routePath,
        name: HomePage.routeName,
        pageBuilder: (context, state) =>
            _noTransitionPage(state, const HomePage()),
      ),
      GoRoute(
        path: ProfilePage.routePath,
        name: ProfilePage.routeName,
        pageBuilder: (context, state) =>
            _noTransitionPage(state, const ProfilePage()),
      ),
      GoRoute(
        path: PaymentHistoryPage.routePath,
        name: PaymentHistoryPage.routeName,
        pageBuilder: (context, state) =>
            _noTransitionPage(state, const PaymentHistoryPage()),
      ),
      GoRoute(
        path: GradeListPage.routePath,
        name: GradeListPage.routeName,
        pageBuilder: (context, state) =>
            _noTransitionPage(state, const GradeListPage()),
      ),
      GoRoute(
        path: LearningCenterPage.routePath,
        name: LearningCenterPage.routeName,
        pageBuilder: (context, state) => _noTransitionPage(
          state,
          LearningCenterPage(
            gradeId: _queryInt(state, 'gradeId'),
            gradeNumber: _queryInt(state, 'gradeNumber'),
            subjectId: _queryInt(state, 'subjectId') ?? 1,
          ),
        ),
      ),
      GoRoute(
        path: LessonListPage.routePath,
        name: LessonListPage.routeName,
        pageBuilder: (context, state) => _noTransitionPage(
          state,
          LessonListPage(
            courseId: state.pathParameters['courseId'] ?? 'algebra',
            gradeId: _queryInt(state, 'gradeId'),
            gradeNumber: _queryInt(state, 'gradeNumber'),
            subjectId: _queryInt(state, 'subjectId'),
          ),
        ),
      ),
      GoRoute(
        path: LessonDetailPage.routePath,
        name: LessonDetailPage.routeName,
        pageBuilder: (context, state) => _noTransitionPage(
          state,
          LessonDetailPage(
            courseId: state.pathParameters['courseId'] ?? 'algebra',
            lessonId: state.pathParameters['lessonId'] ?? 'linear-equations',
            slug: state.uri.queryParameters['slug'],
            gradeId: _queryInt(state, 'gradeId'),
            gradeNumber: _queryInt(state, 'gradeNumber'),
            subjectId: _queryInt(state, 'subjectId'),
          ),
        ),
      ),
      GoRoute(
        path: QuizByLessonPage.routePath,
        name: QuizByLessonPage.routeName,
        pageBuilder: (context, state) {
          final paramId = int.tryParse(state.pathParameters['lessonId'] ?? '');
          final queryId = _queryInt(state, 'lessonId');
          final lessonId = (paramId != null && paramId > 0)
              ? paramId
              : (queryId != null && queryId > 0)
                  ? queryId
                  : 10;
          return _noTransitionPage(
            state,
            QuizByLessonPage(
              lessonId: lessonId,
              size: _queryInt(state, 'size') ?? 15,
            ),
          );
        },
      ),
      GoRoute(
        path: '/quiz-by-lesson',
        name: 'quiz-by-lesson-query',
        pageBuilder: (context, state) {
          final queryId = _queryInt(state, 'lessonId');
          return _noTransitionPage(
            state,
            QuizByLessonPage(
              lessonId: (queryId != null && queryId > 0) ? queryId : 10,
              size: _queryInt(state, 'size') ?? 15,
            ),
          );
        },
      ),
      GoRoute(
        path: BasicCoursePage.routePath,
        name: BasicCoursePage.routeName,
        pageBuilder: (context, state) =>
            _noTransitionPage(state, const BasicCoursePage()),
      ),
      GoRoute(
        path: BasicLessonListPage.routePath,
        name: BasicLessonListPage.routeName,
        pageBuilder: (context, state) => _noTransitionPage(
          state,
          BasicLessonListPage(
            courseId: state.pathParameters['courseId'] ?? 'mathematics',
          ),
        ),
      ),
      GoRoute(
        path: BasicLessonDetailPage.routePath,
        name: BasicLessonDetailPage.routeName,
        pageBuilder: (context, state) => _noTransitionPage(
          state,
          BasicLessonDetailPage(
            courseId: state.pathParameters['courseId'] ?? 'mathematics',
            lessonId: state.pathParameters['lessonId'] ?? 'numbers-operations',
          ),
        ),
      ),
      GoRoute(
        path: AiTutorPage.routePath,
        name: AiTutorPage.routeName,
        pageBuilder: (context, state) {
          final tutorialId = _queryInt(state, 'tutorialId');
          return _noTransitionPage(
            state,
            AiTutorPage(
              tutorialId: (tutorialId != null && tutorialId > 0)
                  ? tutorialId
                  : null,
              lessonTitle: state.uri.queryParameters['title'],
            ),
          );
        },
      ),
      GoRoute(
        path: ResourcePage.routePath,
        name: ResourcePage.routeName,
        pageBuilder: (context, state) =>
            _noTransitionPage(state, const ResourcePage()),
      ),
      GoRoute(
        path: MyStudyPage.routePath,
        name: MyStudyPage.routeName,
        builder: (context, state) => const MyStudyPage(),
      ),
      GoRoute(
        path: ExamTestListPage.routePath,
        name: ExamTestListPage.routeName,
        builder: (context, state) => const ExamTestListPage(),
      ),
      GoRoute(
        path: ExamTestDetailPage.routePath,
        name: ExamTestDetailPage.routeName,
        builder: (context, state) =>
            ExamTestDetailPage(testId: state.pathParameters['testId'] ?? ''),
      ),
      GoRoute(
        path: ResourceYearsPage.routePath,
        name: ResourceYearsPage.routeName,
        pageBuilder: (context, state) => _noTransitionPage(
          state,
          ResourceYearsPage(examId: state.pathParameters['examId'] ?? 'bac-ii'),
        ),
      ),
      GoRoute(
        path: ResourceListByYearsPage.routePath,
        name: ResourceListByYearsPage.routeName,
        pageBuilder: (context, state) => _noTransitionPage(
          state,
          ResourceListByYearsPage(
            examId: state.pathParameters['examId'] ?? 'bac-ii',
            year: int.tryParse(state.pathParameters['year'] ?? '') ?? 2025,
          ),
        ),
      ),
    ],
  );

  ref.onDispose(() {
    router.dispose();
    isSignedIn.dispose();
  });
  return router;
});

bool _isSignedIn(AsyncValue<Object?> authState) {
  return switch (authState) {
    AsyncData(:final value) => value != null,
    _ => false,
  };
}

/// Sends signed-out users to login, and signed-in users away from the
/// login/register pages. Returns null when no redirect is needed.
String? authRedirect({required bool isSignedIn, required String location}) {
  final isPublicRoute = _publicRoutePaths.contains(location);
  if (!isSignedIn) return isPublicRoute ? null : LoginPage.routePath;
  if (isPublicRoute) return HomePage.routePath;
  return null;
}

int? _queryInt(GoRouterState state, String key) {
  return int.tryParse(state.uri.queryParameters[key] ?? '');
}

Page<void> _noTransitionPage(GoRouterState state, Widget child) {
  return NoTransitionPage<void>(key: state.pageKey, child: child);
}
