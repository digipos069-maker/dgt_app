import 'package:dgt_app/features/subscription/presentation/widgets/upgrade_subscription_modal.dart';
import 'package:dgt_app/localization/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _buildTestApp(Widget child) {
  return MaterialApp(
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
  testWidgets('UpgradeSubscriptionModal steps through plan, payment, bank details and submit',
      (tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    bool navigatedToHistory = false;

    await tester.pumpWidget(
      _buildTestApp(
        Builder(
          builder: (context) {
            return Center(
              child: ElevatedButton(
                onPressed: () {
                  showUpgradeSubscriptionModal(
                    context: context,
                    onNavigateToPaymentHistory: () {
                      navigatedToHistory = true;
                    },
                  );
                },
                child: const Text('Open Modal'),
              ),
            );
          },
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Open modal
    await tester.tap(find.text('Open Modal'));
    await tester.pumpAndSettle();

    // Step 0: Plan Selection
    expect(find.text('Choose Your Plan'), findsOneWidget);
    expect(find.text('Monthly'), findsOneWidget);
    expect(find.text('Yearly'), findsOneWidget);
    expect(find.text('Save 20%'), findsOneWidget);
    expect(find.textContaining('\$89.99'), findsWidgets); // Pro yearly price

    // Toggle to Monthly
    await tester.tap(find.text('Monthly'));
    await tester.pumpAndSettle();
    expect(find.textContaining('\$9.99'), findsWidgets); // Monthly Pro price

    // Toggle back to Yearly
    await tester.tap(find.text('Yearly'));
    await tester.pumpAndSettle();
    expect(find.textContaining('\$89.99'), findsWidgets);

    // Select Pro Plan
    final selectProButton = find.widgetWithText(ElevatedButton, 'Select Plan - Pro');
    expect(selectProButton, findsOneWidget);
    await tester.tap(selectProButton);
    await tester.pumpAndSettle();

    // Step 1: Payment Method
    expect(find.text('Payment Method'), findsOneWidget);
    expect(find.text('Bank Transfer'), findsOneWidget);
    expect(find.text('ABA / Bakong KHQR'), findsOneWidget);

    // Continue to Bank Details
    final continueButton = find.widgetWithText(ElevatedButton, 'Continue with Bank Transfer');
    expect(continueButton, findsOneWidget);
    await tester.tap(continueButton);
    await tester.pumpAndSettle();

    // Step 2: Bank Details & Upload Payslip
    expect(find.text('Bank Details'), findsOneWidget);
    expect(find.text('ABA Bank'), findsOneWidget);
    expect(find.text('DGT EDUCATION CO., LTD'), findsOneWidget);
    expect(find.text('000 123 456'), findsOneWidget);
    expect(find.byKey(const Key('upload_payslip_zone')), findsOneWidget);

    // Try submitting without payslip -> should show error
    final submitButton = find.widgetWithText(ElevatedButton, 'Submit Payment');
    await tester.tap(submitButton);
    await tester.pumpAndSettle();
    expect(find.text('Please attach a payslip before submitting.'), findsOneWidget);

    // Tap Upload Payslip zone to attach receipt
    await tester.tap(find.byKey(const Key('upload_payslip_zone')));
    await tester.pumpAndSettle();

    // Modal with preset receipts pops up
    expect(find.text('aba_payment_slip_2026.png'), findsOneWidget);
    await tester.tap(find.text('aba_payment_slip_2026.png'));
    await tester.pumpAndSettle();

    // Payslip is now attached and error cleared
    expect(find.text('Payslip attached successfully'), findsOneWidget);
    expect(find.text('Please attach a payslip before submitting.'), findsNothing);

    // Tap submit payment
    await tester.tap(submitButton);
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();

    // Success dialog pops up
    expect(find.text('Payment Submitted!'), findsOneWidget);
    expect(find.text('View Payment History'), findsOneWidget);

    // Tap View Payment History
    await tester.tap(find.text('View Payment History'));
    await tester.pumpAndSettle();
    expect(navigatedToHistory, isTrue);
  });

  testWidgets('Modal does not overflow on narrow screens', (tester) async {
    // Test on small 320px width device screen
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      _buildTestApp(
        Builder(
          builder: (context) {
            return Center(
              child: ElevatedButton(
                onPressed: () {
                  showUpgradeSubscriptionModal(
                    context: context,
                    onNavigateToPaymentHistory: () {},
                  );
                },
                child: const Text('Open'),
              ),
            );
          },
        ),
      ),
    );

    await tester.pumpAndSettle();
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    // Verify Step 0 (Plan selection & BillingCycleToggle) doesn't overflow
    expect(tester.takeException(), isNull);

    // Select plan to reach step 1 (Payment method)
    final selectBasicButton = find.widgetWithText(ElevatedButton, 'Select Plan - Basic');
    await tester.scrollUntilVisible(selectBasicButton, 100);
    await tester.tap(selectBasicButton);
    await tester.pumpAndSettle();

    // Verify Step 1 (PaymentMethodSelector with Wrap) doesn't overflow
    expect(tester.takeException(), isNull);
    expect(find.text('Bank Transfer'), findsOneWidget);
    expect(find.text('ABA / Bakong KHQR'), findsOneWidget);
  });
}
