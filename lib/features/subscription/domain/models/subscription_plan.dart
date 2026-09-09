import 'package:flutter/material.dart';

enum BillingCycle {
  monthly,
  yearly;

  bool get isMonthly => this == BillingCycle.monthly;
  bool get isYearly => this == BillingCycle.yearly;
}

class PlanTier {
  const PlanTier({
    required this.id,
    required this.name,
    required this.description,
    required this.monthlyPrice,
    required this.yearlyPrice,
    required this.features,
    this.currency = 'USD',
    this.currencySymbol = '\$',
    this.isPopular = false,
    this.icon = Icons.star_border_rounded,
  });

  final String id;
  final String name;
  final String description;
  final double monthlyPrice;
  final double yearlyPrice;
  final String currency;
  final String currencySymbol;
  final List<String> features;
  final bool isPopular;
  final IconData icon;

  double priceFor(BillingCycle cycle) =>
      cycle.isMonthly ? monthlyPrice : yearlyPrice;

  String formattedPrice(BillingCycle cycle) {
    final price = priceFor(cycle);
    return '$currencySymbol${price.toStringAsFixed(2)}';
  }

  String monthlyEquivalentPrice() {
    final eq = yearlyPrice / 12;
    return '$currencySymbol${eq.toStringAsFixed(2)}';
  }

  static const List<PlanTier> defaultPlans = [
    PlanTier(
      id: 'plan_basic',
      name: 'Basic',
      description: 'Essential access for individual students.',
      monthlyPrice: 4.99,
      yearlyPrice: 47.99,
      icon: Icons.school_outlined,
      features: [
        'Access to all foundation lessons',
        'Standard multiple choice quizzes',
        'Standard video lessons & exercises',
        'Community discussion support',
      ],
    ),
    PlanTier(
      id: 'plan_pro',
      name: 'Pro',
      description: 'The most popular plan for active exam mastery.',
      monthlyPrice: 9.99,
      yearlyPrice: 89.99,
      isPopular: true,
      icon: Icons.workspace_premium_outlined,
      features: [
        'Everything in Basic',
        'Interactive Matching & Drag-and-Drop quizzes',
        'Unlimited AI Tutor explanations',
        'Downloadable lessons & offline practice',
        'Priority progress analytics',
      ],
    ),
    PlanTier(
      id: 'plan_premium',
      name: 'Premium',
      description: 'Ultimate learning bundle with mentor review.',
      monthlyPrice: 19.99,
      yearlyPrice: 179.99,
      icon: Icons.diamond_outlined,
      features: [
        'Everything in Pro',
        '1-on-1 Mentor feedback on practice exams',
        'Full past exam papers with solution PDFs',
        'Multi-device family sub-account support',
        'Verified Certificate of Completion',
      ],
    ),
  ];
}
