import 'package:dgt_app/features/auth/domain/models/profile_models.dart';
import 'package:dgt_app/features/auth/domain/models/user_model.dart';
import 'package:dgt_app/features/auth/presentation/widgets/profile_body.dart';
import 'package:dgt_app/localization/app_localizations.dart';
import 'package:dgt_app/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dgt_app/theme/app_theme.dart';

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
  testWidgets('ProfileBody renders Upgrade button in subscription section and fires callback',
      (tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    bool upgradePressed = false;

    const testUser = UserModel(
      id: 'u1',
      email: 'student@example.com',
      username: 'Student A',
      subscriptions: [
        SubscriptionModel(
          id: 'sub1',
          status: 'active',
          subAccountLimit: 1,
          startAt: null,
          endAt: null,
          plan: SubscriptionPlanModel(
            id: 'basic',
            name: 'Basic Plan',
            price: 4.99,
            currency: 'USD',
            isActive: true,
          ),
        ),
      ],
    );

    await tester.pumpWidget(
      _buildTestApp(
        ProfileBody(
          user: testUser,
          isProfileLoading: false,
          onPaymentHistory: () {},
          onLogout: () {},
          onUpgradeSubscription: () {
            upgradePressed = true;
          },
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify upgrade button exists with key 'profile_upgrade_button'
    final upgradeButtonFinder = find.byKey(const Key('profile_upgrade_button'));
    expect(upgradeButtonFinder, findsOneWidget);

    // Verify the button has the main primary color
    final buttonWidget = tester.widget<ElevatedButton>(upgradeButtonFinder);
    final bg = buttonWidget.style?.backgroundColor?.resolve({});
    expect(bg, AppColors.primary);

    // Tap upgrade button
    await tester.tap(upgradeButtonFinder);
    await tester.pumpAndSettle();

    expect(upgradePressed, isTrue);
  });
}
