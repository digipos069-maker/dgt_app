import 'package:dgt_app/core/utils/app_exception.dart';
import 'package:dgt_app/features/auth/application/auth_controller.dart';
import 'package:dgt_app/features/auth/domain/models/user_model.dart';
import 'package:dgt_app/features/subscription/application/subscription_controller.dart';
import 'package:dgt_app/features/subscription/data/subscription_repository.dart';
import 'package:dgt_app/features/subscription/domain/models/subscription_plan.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _MockSubscriptionRepo implements SubscriptionRepository {
  int uploadCallCount = 0;
  int submitCallCount = 0;
  int upgradeCallCount = 0;

  @override
  Future<String> uploadPayslip({
    required List<int> fileBytes,
    required String filename,
    required String token,
  }) async {
    uploadCallCount++;
    return '/uploads/payslip-123.jpg';
  }

  @override
  Future<Map<String, dynamic>> submitBankTransfer({
    required int planId,
    required num amount,
    required String currency,
    required String billingCycle,
    required String payslipUrl,
    required String token,
  }) async {
    submitCallCount++;
    return {
      'message': 'Bank transfer submitted and is pending verification',
      'trxId': 'BT-98765',
    };
  }

  @override
  Future<Map<String, dynamic>> upgradeSubscription({
    required int newPlanId,
    required String token,
  }) async {
    upgradeCallCount++;
    return {
      'id': 15,
      'planId': newPlanId,
      'status': 'pending',
    };
  }
}

class _FakeAuth extends AuthController {
  _FakeAuth(this._user);
  final UserModel? _user;

  @override
  Future<UserModel?> build() async => _user;
}

void main() {
  group('SubscriptionController', () {
    test('submitBankTransfer uploads payslip and submits payment', () async {
      final repo = _MockSubscriptionRepo();
      final container = ProviderContainer(
        overrides: [
          authControllerProvider.overrideWith(
            () => _FakeAuth(
              const UserModel(
                id: '1',
                email: 'student@test.com',
                username: 'student',
                token: 'token-123',
              ),
            ),
          ),
          subscriptionRepositoryProvider.overrideWithValue(repo),
        ],
      );
      addTearDown(container.dispose);

      final premiumPlan = PLANS.firstWhere((p) => p.id == 2);
      final result = await container
          .read(subscriptionControllerProvider.notifier)
          .submitBankTransfer(
            plan: premiumPlan,
            cycle: BillingCycle.monthly,
            fileName: 'my_slip.png',
            currency: 'khr',
          );

      expect(repo.uploadCallCount, 1);
      expect(repo.submitCallCount, 1);
      expect(result['trxId'], 'BT-98765');
      expect(result['message'],
          'Bank transfer submitted and is pending verification');
    });

    test('upgradeSubscriptionDirectly calls upgrade API', () async {
      final repo = _MockSubscriptionRepo();
      final container = ProviderContainer(
        overrides: [
          authControllerProvider.overrideWith(
            () => _FakeAuth(
              const UserModel(
                id: '1',
                email: 'student@test.com',
                username: 'student',
                token: 'token-123',
              ),
            ),
          ),
          subscriptionRepositoryProvider.overrideWithValue(repo),
        ],
      );
      addTearDown(container.dispose);

      final result = await container
          .read(subscriptionControllerProvider.notifier)
          .upgradeSubscriptionDirectly(newPlanId: 2);

      expect(repo.upgradeCallCount, 1);
      expect(result['planId'], 2);
      expect(result['status'], 'pending');
    });

    test('throws AppException when user is not logged in', () async {
      final repo = _MockSubscriptionRepo();
      final container = ProviderContainer(
        overrides: [
          authControllerProvider.overrideWith(() => _FakeAuth(null)),
          subscriptionRepositoryProvider.overrideWithValue(repo),
        ],
      );
      addTearDown(container.dispose);

      final premiumPlan = PLANS.firstWhere((p) => p.id == 2);

      expect(
        () => container
            .read(subscriptionControllerProvider.notifier)
            .submitBankTransfer(
              plan: premiumPlan,
              cycle: BillingCycle.monthly,
              fileName: 'my_slip.png',
            ),
        throwsA(
          isA<AppException>().having(
            (e) => e.message,
            'message',
            contains('Please log in'),
          ),
        ),
      );
    });
  });
}
