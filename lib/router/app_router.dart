import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/presentation/pages/home_page.dart';
import '../features/auth/presentation/pages/login_page.dart';
import '../features/auth/presentation/pages/payment_history_page.dart';
import '../features/auth/presentation/pages/profile_page.dart';
import '../features/auth/presentation/pages/register_page.dart';
import '../features/home/presentation/pages/ai_tutor_page.dart';
import '../features/home/presentation/pages/basic_course_page.dart';
import '../features/home/presentation/pages/basic_lesson_detail_page.dart';
import '../features/home/presentation/pages/basic_lesson_list_page.dart';
import '../features/home/presentation/pages/learning_center_page.dart';
import '../features/home/presentation/pages/lesson_detail_page.dart';
import '../features/home/presentation/pages/lesson_list_page.dart';
import '../features/home/presentation/pages/resource_page.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: LoginPage.routePath,
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
        path: LearningCenterPage.routePath,
        name: LearningCenterPage.routeName,
        pageBuilder: (context, state) =>
            _noTransitionPage(state, const LearningCenterPage()),
      ),
      GoRoute(
        path: LessonListPage.routePath,
        name: LessonListPage.routeName,
        pageBuilder: (context, state) => _noTransitionPage(
          state,
          LessonListPage(
            courseId: state.pathParameters['courseId'] ?? 'algebra',
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

Page<void> _noTransitionPage(GoRouterState state, Widget child) {
  return NoTransitionPage<void>(key: state.pageKey, child: child);
}
