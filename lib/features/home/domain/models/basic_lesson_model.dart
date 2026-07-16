import 'basic_course_model.dart';

class BasicLessonModel {
  const BasicLessonModel({
    required this.id,
    required this.courseId,
    required this.name,
    required this.thumbnail,
    required this.description,
    required this.durationLabel,
  });

  factory BasicLessonModel.fromJson(
    Map<String, dynamic> json, {
    required String courseId,
  }) {
    return BasicLessonModel(
      id: json['id']?.toString() ?? '',
      courseId: courseId,
      name: json['name']?.toString() ?? '',
      thumbnail: json['thumbnail']?.toString() ?? '',
      description: (json['description'] ?? json['desc'])?.toString() ?? '',
      durationLabel:
          (json['durationLabel'] ?? json['duration'])?.toString() ?? '',
    );
  }

  final String id;
  final String courseId;
  final String name;
  final String thumbnail;
  final String description;
  final String durationLabel;
}

class BasicLessonBundle {
  const BasicLessonBundle({required this.course, required this.lessons});

  final BasicCourseModel course;
  final List<BasicLessonModel> lessons;
}
