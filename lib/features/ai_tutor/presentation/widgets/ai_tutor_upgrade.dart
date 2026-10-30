import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../../../auth/presentation/pages/payment_history_page.dart';
import '../../../subscription/presentation/widgets/upgrade_subscription_modal.dart';

/// Opens the app's existing "upgrade subscription" sheet from the AI tutor.
Future<void> openAiTutorUpgrade(BuildContext context) {
  return showUpgradeSubscriptionModal(
    context: context,
    onNavigateToPaymentHistory: () => context.goNamed(PaymentHistoryPage.routeName),
  );
}

/// dd/MM/yyyy (the app has no intl dependency).
String formatAiTutorDate(DateTime date) {
  String two(int value) => value.toString().padLeft(2, '0');
  return '${two(date.day)}/${two(date.month)}/${date.year}';
}
