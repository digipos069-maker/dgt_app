import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'subscription_api_service.dart';

final subscriptionApiServiceProvider = Provider<SubscriptionApiService>((ref) {
  return SubscriptionApiService();
});

final subscriptionRepositoryProvider = Provider<SubscriptionRepository>((ref) {
  return SubscriptionRepository(ref.watch(subscriptionApiServiceProvider));
});

class SubscriptionRepository {
  SubscriptionRepository(this._apiService);

  final SubscriptionApiService _apiService;

  Future<String> uploadPayslip({
    required List<int> fileBytes,
    required String filename,
    required String token,
  }) {
    return _apiService.uploadPayslip(
      fileBytes: fileBytes,
      filename: filename,
      token: token,
    );
  }

  Future<Map<String, dynamic>> submitBankTransfer({
    required int planId,
    required num amount,
    required String currency,
    required String billingCycle,
    required String payslipUrl,
    required String token,
  }) {
    return _apiService.submitBankTransfer(
      planId: planId,
      amount: amount,
      currency: currency,
      billingCycle: billingCycle,
      payslipUrl: payslipUrl,
      token: token,
    );
  }

  Future<Map<String, dynamic>> upgradeSubscription({
    required int newPlanId,
    required String token,
  }) {
    return _apiService.upgradeSubscription(
      newPlanId: newPlanId,
      token: token,
    );
  }
}
