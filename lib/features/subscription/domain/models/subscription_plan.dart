import 'package:flutter/material.dart';

enum BillingCycle {
  monthly,
  yearly;

  bool get isMonthly => this == BillingCycle.monthly;
  bool get isYearly => this == BillingCycle.yearly;
}

class PlanPrice {
  const PlanPrice({
    required this.usd,
    required this.khr,
  });

  final double usd;
  final double khr;

  factory PlanPrice.fromJson(Map<String, dynamic> json) {
    return PlanPrice(
      usd: (json['usd'] as num?)?.toDouble() ?? 0.0,
      khr: (json['khr'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
        'usd': usd,
        'khr': khr,
      };
}

class SubscriptionPlan {
  const SubscriptionPlan({
    required this.id,
    required this.name,
    required this.price,
    this.description = '',
    this.features = const [],
    this.isPopular = false,
    this.icon = Icons.star_border_rounded,
    this.yearlyPriceUsd,
    this.yearlyPriceKhr,
  });

  final int id;
  final String name;
  final PlanPrice price;
  final String description;
  final List<String> features;
  final bool isPopular;
  final IconData icon;
  final double? yearlyPriceUsd;
  final double? yearlyPriceKhr;

  bool get isFree => price.usd == 0 && price.khr == 0;

  String get displayName {
    if (name.isEmpty) return '';
    return name[0].toUpperCase() + name.substring(1);
  }

  double priceFor(BillingCycle cycle) {
    if (isFree) return 0.0;
    if (cycle.isMonthly) {
      return price.usd;
    }
    return yearlyPriceUsd ?? (price.usd * 12 * 0.8);
  }

  double priceKhrFor(BillingCycle cycle) {
    if (isFree) return 0.0;
    if (cycle.isMonthly) {
      return price.khr;
    }
    return yearlyPriceKhr ?? (price.khr * 12 * 0.8);
  }

  String formattedPrice(BillingCycle cycle, {bool includeKhr = false}) {
    if (isFree) return '\$0.00';
    final usdPrice = priceFor(cycle);
    final usdText = '\$${usdPrice.toStringAsFixed(2)}';
    if (!includeKhr || price.khr <= 0) return usdText;
    final khrVal = priceKhrFor(cycle).round();
    return '$usdText (${formatKhr(khrVal)} ៛)';
  }

  String monthlyEquivalentPrice() {
    if (isFree) return '\$0.00';
    final yearly = priceFor(BillingCycle.yearly);
    final eq = yearly / 12;
    return '\$${eq.toStringAsFixed(2)}';
  }

  static String formatKhr(int amount) {
    return amount.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlan(
      id: json['id'] as int,
      name: json['name'] as String,
      price: PlanPrice.fromJson(json['price'] as Map<String, dynamic>),
      description: json['description'] as String? ?? '',
      features: (json['features'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      isPopular: json['isPopular'] as bool? ?? false,
      yearlyPriceUsd: (json['yearlyPriceUsd'] as num?)?.toDouble(),
      yearlyPriceKhr: (json['yearlyPriceKhr'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'price': price.toJson(),
      };

  static const List<SubscriptionPlan> defaultPlans = PLANS;
}

typedef PlanTier = SubscriptionPlan;

/// Predefined plans matching:
/// export const PLANS = [
///   { id: 1, name: 'free', price: { usd: 0.00, khr: 0.00 } },
///   { id: 2, name: 'premium', price: { usd: 2.99, khr: 12000.00 } },
/// ];
// ignore: constant_identifier_names
const List<SubscriptionPlan> PLANS = [
  SubscriptionPlan(
    id: 2,
    name: 'premium',
    price: PlanPrice(
      usd: 2.99,
      khr: 12000.00,
    ),
    yearlyPriceUsd: 28.70,
    yearlyPriceKhr: 115000.00,
    isPopular: true,
    icon: Icons.workspace_premium_outlined,
    description:
        'Unlock all interactive quizzes, offline lessons & unlimited practice.',
    features: [
      'All interactive quizzes (Matching & Drag-and-Drop)',
      'Unlimited lesson access & offline downloads',
      'Detailed answer explanations & exam mastery',
      'Priority student support & progress analytics',
      'Multi-currency checkout: USD or KHR (Bakong / ABA)',
    ],
  ),
];
