class BasicCourseModel {
  const BasicCourseModel({
    required this.id,
    required this.name,
    required this.thumbnail,
    required this.description,
  });

  factory BasicCourseModel.fromJson(Map<String, dynamic> json) {
    return BasicCourseModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      thumbnail: json['thumbnail']?.toString() ?? '',
      description: (json['description'] ?? json['desc'])?.toString() ?? '',
    );
  }

  final String id;
  final String name;
  final String thumbnail;
  final String description;
}
