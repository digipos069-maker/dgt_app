import 'package:dgt_app/features/subscription/domain/models/bank_transfer_info.dart';
import 'package:dgt_app/features/subscription/domain/models/subscription_plan.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SubscriptionPlanModel & PlanTier', () {
    test('PLANS contains premium plan instance', () {
      final plans = SubscriptionPlan.defaultPlans;
      expect(plans.length, 1);

      final premium = plans.firstWhere((p) => p.id == 2);
      expect(premium.name, 'premium');
      expect(premium.displayName, 'Premium');
      expect(premium.price.usd, 2.99);
      expect(premium.price.khr, 12000.00);
      expect(premium.isPopular, isTrue);
    });

    test('priceFor and priceKhrFor return correct prices for monthly vs yearly', () {
      final premiumPlan = SubscriptionPlan.defaultPlans.firstWhere((p) => p.id == 2);
      expect(premiumPlan.priceFor(BillingCycle.monthly), 2.99);
      expect(premiumPlan.priceFor(BillingCycle.yearly), 28.70);
      expect(premiumPlan.priceKhrFor(BillingCycle.monthly), 12000.00);
      expect(premiumPlan.priceKhrFor(BillingCycle.yearly), 115000.00);
      expect(premiumPlan.formattedPrice(BillingCycle.monthly), '\$2.99');
      expect(premiumPlan.formattedPrice(BillingCycle.yearly), '\$28.70');
      expect(premiumPlan.formattedPrice(BillingCycle.monthly, includeKhr: true), '\$2.99 (12,000 ៛)');
    });

    test('monthlyEquivalentPrice calculates correct discount rate', () {
      final premiumPlan = SubscriptionPlan.defaultPlans.firstWhere((p) => p.id == 2);
      expect(premiumPlan.monthlyEquivalentPrice(), '\$2.39');
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
