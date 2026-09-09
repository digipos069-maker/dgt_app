import 'package:dgt_app/features/auth/domain/models/user_model.dart';
import 'package:dgt_app/features/auth/presentation/widgets/profile_body.dart';
import 'package:dgt_app/localization/app_localizations.dart';
import 'package:dgt_app/theme/app_colors.dart';
import 'package:dgt_app/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _buildTestApp(Widget child) {
  return MaterialApp(
    theme: AppTheme.light(const Locale('en')),
    locale: const Locale('en'),
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: const [
      AppLocalizations.delegate,
      DefaultWidgetsLocalizations.delegate,
      DefaultMaterialLocalizations.delegate,
    ],
    home: Scaffold(body: child),
  );
}

void main() {
  testWidgets('ProfileBody renders RefreshIndicator with primary color and triggers onRefresh when pulled down',
      (tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    bool refreshed = false;

    const testUser = UserModel(
      id: 'u1',
      email: 'student@example.com',
      username: 'Student A',
    );

    await tester.pumpWidget(
      _buildTestApp(
        ProfileBody(
          user: testUser,
          isProfileLoading: false,
          onPaymentHistory: () {},
          onLogout: () {},
          onRefresh: () async {
            refreshed = true;
          },
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify RefreshIndicator exists
    final refreshIndicatorFinder = find.byType(RefreshIndicator);
    expect(refreshIndicatorFinder, findsOneWidget);

    final indicatorWidget = tester.widget<RefreshIndicator>(refreshIndicatorFinder);
    expect(indicatorWidget.color, AppColors.primary);

    // Pull down to refresh
    await tester.fling(find.byType(SingleChildScrollView), const Offset(0, 400), 1000);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(refreshed, isTrue);
  });
}
