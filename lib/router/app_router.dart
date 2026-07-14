import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/presentation/pages/home_page.dart';
import '../features/auth/presentation/pages/login_page.dart';
import '../features/auth/presentation/pages/register_page.dart';
import '../features/home/presentation/pages/ai_tutor_page.dart';
import '../features/home/presentation/pages/learning_center_page.dart';
import '../features/home/presentation/pages/lesson_detail_page.dart';
import '../features/home/presentation/pages/lesson_list_page.dart';
import '../features/home/presentation/pages/my_learning_page.dart';
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
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: LearningCenterPage.routePath,
        name: LearningCenterPage.routeName,
        builder: (context, state) => const LearningCenterPage(),
      ),
      GoRoute(
        path: LessonListPage.routePath,
        name: LessonListPage.routeName,
        builder: (context, state) {
          return LessonListPage(
            courseId: state.pathParameters['courseId'] ?? 'algebra',
          );
        },
      ),
      GoRoute(
        path: LessonDetailPage.routePath,
        name: LessonDetailPage.routeName,
        builder: (context, state) {
          return LessonDetailPage(
            courseId: state.pathParameters['courseId'] ?? 'algebra',
            lessonId: state.pathParameters['lessonId'] ?? 'linear-equations',
          );
        },
      ),
      GoRoute(
        path: MyLearningPage.routePath,
        name: MyLearningPage.routeName,
        builder: (context, state) => const MyLearningPage(),
      ),
      GoRoute(
        path: AiTutorPage.routePath,
        name: AiTutorPage.routeName,
        builder: (context, state) => const AiTutorPage(),
      ),
      GoRoute(
        path: ResourcePage.routePath,
        name: ResourcePage.routeName,
        builder: (context, state) => const ResourcePage(),
      ),
    ],
  );
});
