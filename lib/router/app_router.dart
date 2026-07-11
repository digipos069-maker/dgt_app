import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/presentation/pages/home_page.dart';
import '../features/auth/presentation/pages/login_page.dart';
import '../features/auth/presentation/pages/register_page.dart';

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
    ],
  );
});
