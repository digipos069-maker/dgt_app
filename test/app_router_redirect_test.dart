import 'package:dgt_app/features/auth/presentation/pages/home_page.dart';
import 'package:dgt_app/features/auth/presentation/pages/login_page.dart';
import 'package:dgt_app/features/auth/presentation/pages/profile_page.dart';
import 'package:dgt_app/features/auth/presentation/pages/register_page.dart';
import 'package:dgt_app/router/app_router.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('signed out', () {
    test('protected pages redirect to login', () {
      for (final location in [
        HomePage.routePath,
        ProfilePage.routePath,
        '/lessons/algebra',
      ]) {
        expect(
          authRedirect(isSignedIn: false, location: location),
          LoginPage.routePath,
          reason: location,
        );
      }
    });

    test('login and register stay open', () {
      expect(
        authRedirect(isSignedIn: false, location: LoginPage.routePath),
        isNull,
      );
      expect(
        authRedirect(isSignedIn: false, location: RegisterPage.routePath),
        isNull,
      );
    });
  });

  group('signed in', () {
    test('login and register redirect home', () {
      expect(
        authRedirect(isSignedIn: true, location: LoginPage.routePath),
        HomePage.routePath,
      );
      expect(
        authRedirect(isSignedIn: true, location: RegisterPage.routePath),
        HomePage.routePath,
      );
    });

    test('protected pages stay open', () {
      expect(authRedirect(isSignedIn: true, location: HomePage.routePath), isNull);
      expect(
        authRedirect(isSignedIn: true, location: ProfilePage.routePath),
        isNull,
      );
    });
  });
}
