/// The student's monthly AI tutor token allowance (from their plan).
class AiTutorUsage {
  const AiTutorUsage({
    required this.planName,
    required this.limit,
    required this.used,
    required this.remaining,
    this.resetsAt,
  });

  factory AiTutorUsage.fromJson(Map<String, dynamic> json) {
    int readInt(Object? value) => value is num ? value.toInt() : int.tryParse('$value') ?? 0;
    return AiTutorUsage(
      planName: (json['planName'] ?? '').toString(),
      limit: readInt(json['limit']),
      used: readInt(json['used']),
      remaining: readInt(json['remaining']),
      resetsAt: DateTime.tryParse('${json['resetsAt']}')?.toLocal(),
    );
  }

  final String planName;
  final int limit;
  final int used;
  final int remaining;
  final DateTime? resetsAt;

  bool get isExhausted => remaining <= 0;

  /// 0.0 – 1.0 share of the allowance still available.
  double get remainingFraction =>
      limit <= 0 ? 0 : (remaining / limit).clamp(0.0, 1.0);
}
