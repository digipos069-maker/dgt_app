class ExamResourceModel {
  const ExamResourceModel({
    required this.id,
    required this.examName,
    required this.icon,
    required this.shortDescription,
  });

  factory ExamResourceModel.fromJson(Map<String, dynamic> json) {
    return ExamResourceModel(
      id: json['id']?.toString() ?? '',
      examName: (json['name'] ?? json['examName'])?.toString() ?? '',
      icon: json['icon']?.toString() ?? 'exam',
      shortDescription:
          (json['description'] ?? json['shortDescription'])?.toString() ?? '',
    );
  }

  final String id;
  final String examName;
  final String icon;
  final String shortDescription;
}
