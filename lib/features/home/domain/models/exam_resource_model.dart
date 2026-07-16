class ExamResourceModel {
  const ExamResourceModel({
    required this.id,
    required this.examName,
    required this.icon,
    required this.isLocked,
    required this.shortDescription,
  });

  factory ExamResourceModel.fromJson(Map<String, dynamic> json) {
    return ExamResourceModel(
      id: json['id']?.toString() ?? '',
      examName: json['examName']?.toString() ?? '',
      icon: json['icon']?.toString() ?? 'exam',
      isLocked: json['isLocked'] == true,
      shortDescription:
          (json['shortDescription'] ?? json['description'])?.toString() ?? '',
    );
  }

  final String id;
  final String examName;
  final String icon;
  final bool isLocked;
  final String shortDescription;
}
