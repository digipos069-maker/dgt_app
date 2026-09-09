import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/app_exception.dart';
import '../../auth/application/auth_controller.dart';
import '../../auth/application/profile_controller.dart';
import '../data/subscription_repository.dart';
import '../domain/models/subscription_plan.dart';

final subscriptionControllerProvider =
    NotifierProvider<SubscriptionController, AsyncValue<Map<String, dynamic>?>>(
  SubscriptionController.new,
);

class SubscriptionController
    extends Notifier<AsyncValue<Map<String, dynamic>?>> {
  @override
  AsyncValue<Map<String, dynamic>?> build() {
    return const AsyncData(null);
  }

  /// 1. POST /api/payment/upload-payslip -> get url
  /// 2. POST /api/payment/bank-transfer -> submit payment
  /// Returns result containing { 'message': ..., 'trxId': ... }
  Future<Map<String, dynamic>> submitBankTransfer({
    required SubscriptionPlan plan,
    required BillingCycle cycle,
    required String fileName,
    List<int>? fileBytes,
    String currency = 'khr',
  }) async {
    final authState = ref.read(authControllerProvider);
    final user = switch (authState) {
      AsyncData(:final value) => value,
      _ => await ref.read(authControllerProvider.future),
    };
    final token = user?.token;

    if (user == null || token == null || token.isEmpty) {
      throw const AppException('Please log in to upgrade your subscription');
    }

    state = const AsyncLoading();

    try {
      final repository = ref.read(subscriptionRepositoryProvider);

      // 1. Upload payslip
      final bytes = fileBytes ?? samplePngBytes();
      final payslipUrl = await repository.uploadPayslip(
        fileBytes: bytes,
        filename: fileName,
        token: token,
      );

      // 2. Submit bank transfer
      final amount = currency.toLowerCase() == 'khr'
          ? plan.priceKhrFor(cycle).round()
          : plan.priceFor(cycle);

      final result = await repository.submitBankTransfer(
        planId: plan.id,
        amount: amount,
        currency: currency,
        billingCycle: cycle.isMonthly ? 'monthly' : 'yearly',
        payslipUrl: payslipUrl,
        token: token,
      );

      // Invalidate profile to pull latest subscription state
      ref.invalidate(profileProvider);

      state = AsyncData(result);
      return result;
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  /// 3. POST /api/upgrade-subscription
  /// Direct plan upgrade
  Future<Map<String, dynamic>> upgradeSubscriptionDirectly({
    required int newPlanId,
  }) async {
    final authState = ref.read(authControllerProvider);
    final user = switch (authState) {
      AsyncData(:final value) => value,
      _ => await ref.read(authControllerProvider.future),
    };
    final token = user?.token;

    if (user == null || token == null || token.isEmpty) {
      throw const AppException('Please log in to upgrade your subscription');
    }

    state = const AsyncLoading();

    try {
      final repository = ref.read(subscriptionRepositoryProvider);
      final result = await repository.upgradeSubscription(
        newPlanId: newPlanId,
        token: token,
      );

      ref.invalidate(profileProvider);

      state = AsyncData(result);
      return result;
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  /// Valid minimal 1x1 PNG bytes for testing or preset uploads
  static List<int> samplePngBytes() {
    return const [
      0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D,
      0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
      0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00,
      0x0A, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
      0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49,
      0x45, 0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82,
    ];
  }
}
