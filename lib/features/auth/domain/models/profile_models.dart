class SubscriptionPlanModel {
  const SubscriptionPlanModel({
    required this.id,
    required this.name,
    required this.price,
    required this.currency,
    required this.isActive,
  });

  factory SubscriptionPlanModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlanModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      price: _readNumber(json['price']),
      currency: json['currency']?.toString() ?? '',
      isActive: json['isActive'] == true,
    );
  }

  final String id;
  final String name;
  final num price;
  final String currency;
  final bool isActive;
}

class SubscriptionModel {
  const SubscriptionModel({
    required this.id,
    required this.status,
    required this.subAccountLimit,
    required this.startAt,
    required this.endAt,
    required this.plan,
  });

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) {
    final planJson = _asMap(json['plan']) ?? const <String, dynamic>{};

    return SubscriptionModel(
      id: json['id']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      subAccountLimit: _readInt(json['subAccountLimit']),
      startAt: DateTime.tryParse(json['startAt']?.toString() ?? ''),
      endAt: DateTime.tryParse(json['endAt']?.toString() ?? ''),
      plan: SubscriptionPlanModel.fromJson(planJson),
    );
  }

  final String id;
  final String status;
  final int subAccountLimit;
  final DateTime? startAt;
  final DateTime? endAt;
  final SubscriptionPlanModel plan;
}

class PaymentHistoryModel {
  const PaymentHistoryModel({
    required this.id,
    required this.transactionId,
    required this.paymentType,
    required this.currency,
    required this.amount,
    required this.status,
    required this.payslipUrl,
    required this.createdAt,
  });

  factory PaymentHistoryModel.fromJson(Map<String, dynamic> json) {
    return PaymentHistoryModel(
      id: json['id']?.toString() ?? '',
      transactionId: json['trxId']?.toString() ?? '',
      paymentType: json['paymentType']?.toString() ?? '',
      currency: json['paymentUsername']?.toString() ?? '',
      amount: _readNumber(json['amount']),
      status: json['status']?.toString() ?? '',
      payslipUrl: json['payslipUrl']?.toString(),
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
    );
  }

  final String id;
  final String transactionId;
  final String paymentType;
  final String currency;
  final num amount;
  final String status;
  final String? payslipUrl;
  final DateTime? createdAt;
}

Map<String, dynamic>? _asMap(Object? value) {
  return value is Map<String, dynamic> ? value : null;
}

num _readNumber(Object? value) {
  if (value is num) return value;
  return num.tryParse(value?.toString() ?? '') ?? 0;
}

int _readInt(Object? value) {
  if (value is int) return value;
  return int.tryParse(value?.toString() ?? '') ?? 0;
}
