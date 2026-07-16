import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../localization/app_localizations.dart';
import '../../../home/presentation/widgets/main_bottom_navigation.dart';
import '../../application/profile_controller.dart';
import '../widgets/language_menu_button.dart';
import '../widgets/payment_history_body.dart';
import '../widgets/theme_toggle_button.dart';
import 'profile_page.dart';

class PaymentHistoryPage extends ConsumerWidget {
  const PaymentHistoryPage({super.key});

  static const routeName = 'payment-history';
  static const routePath = '/profile/payment-history';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(profileProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.goNamed(ProfilePage.routeName),
          icon: const Icon(Icons.arrow_back),
        ),
        title: Text(context.l10n.text('paymentHistory')),
        actions: const [
          LanguageMenuButton(),
          ThemeToggleButton(),
          SizedBox(width: AppSizes.spacing8),
        ],
      ),
      body: profileState.when(
        data: (user) => PaymentHistoryBody(
          payments: user?.paymentHistory ?? const [],
          onRefresh: () async {
            final _ = await ref.refresh(profileProvider.future);
          },
        ),
        error: (_, _) => _PaymentHistoryError(
          onRetry: () => ref.invalidate(profileProvider),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
      bottomNavigationBar: const MainBottomNavigation(selectedIndex: 0),
    );
  }
}

class _PaymentHistoryError extends StatelessWidget {
  const _PaymentHistoryError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.spacing24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_off_outlined,
              size: 52,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: AppSizes.spacing16),
            Text(
              context.l10n.text('paymentHistoryLoadFailed'),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.spacing16),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: Text(context.l10n.text('retry')),
            ),
          ],
        ),
      ),
    );
  }
}
