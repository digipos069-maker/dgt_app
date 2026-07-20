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
import '../features/home/presentation/pages/basic_lesson_detail_page.dart';
import '../features/home/presentation/pages/basic_lesson_list_page.dart';
import '../features/home/presentation/pages/grade_list_page.dart';
import '../features/home/presentation/pages/learning_center_page.dart';
import '../features/home/presentation/pages/lesson_detail_page.dart';
import '../features/home/presentation/pages/lesson_list_page.dart';
import '../features/home/presentation/pages/resource_page.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final isAuthenticated = ref.watch(
    authControllerProvider.select(
      (authState) => switch (authState) {
        AsyncData(:final value) => value != null,
        _ => false,
      },
    ),
  );

  return GoRouter(
    initialLocation: isAuthenticated ? HomePage.routePath : LoginPage.routePath,
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
            gradeId: _queryInt(state, 'gradeId'),
            gradeNumber: _queryInt(state, 'gradeNumber'),
            subjectId: _queryInt(state, 'subjectId'),
          ),
        ),
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
        pageBuilder: (context, state) =>
            _noTransitionPage(state, const AiTutorPage()),
      ),
      GoRoute(
        path: ResourcePage.routePath,
        name: ResourcePage.routeName,
        pageBuilder: (context, state) =>
            _noTransitionPage(state, const ResourcePage()),
      ),
    ],
  );
});

int? _queryInt(GoRouterState state, String key) {
  return int.tryParse(state.uri.queryParameters[key] ?? '');
}

Page<void> _noTransitionPage(GoRouterState state, Widget child) {
  return NoTransitionPage<void>(key: state.pageKey, child: child);
}
