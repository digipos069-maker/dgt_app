import 'package:dgt_app/features/subscription/domain/models/bank_transfer_info.dart';
import 'package:dgt_app/features/subscription/domain/models/subscription_plan.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SubscriptionPlanModel & PlanTier', () {
    test('default plans list contains Basic, Pro and Premium tiers', () {
      final plans = PlanTier.defaultPlans;
      expect(plans.length, 3);
      expect(plans.any((p) => p.name == 'Basic'), isTrue);
      expect(plans.any((p) => p.name == 'Pro' && p.isPopular), isTrue);
      expect(plans.any((p) => p.name == 'Premium'), isTrue);
    });

    test('priceFor returns appropriate price for monthly vs yearly', () {
      final proPlan = PlanTier.defaultPlans.firstWhere((p) => p.name == 'Pro');
      expect(proPlan.priceFor(BillingCycle.monthly), 9.99);
      expect(proPlan.priceFor(BillingCycle.yearly), 89.99);
      expect(proPlan.formattedPrice(BillingCycle.monthly), '\$9.99');
      expect(proPlan.formattedPrice(BillingCycle.yearly), '\$89.99');
    });

    test('monthlyEquivalentPrice calculates correct discount rate', () {
      final proPlan = PlanTier.defaultPlans.firstWhere((p) => p.name == 'Pro');
      expect(proPlan.monthlyEquivalentPrice(), '\$7.50');
    });

    test('BankTransferInfo default ABA details are valid', () {
      const bank = BankTransferInfo.defaultAba;
      expect(bank.bankName, 'ABA Bank');
      expect(bank.accountName, 'DGT EDUCATION CO., LTD');
      expect(bank.accountNumber, '000 123 456');
      expect(bank.currency, 'USD');
    });
  });
}
