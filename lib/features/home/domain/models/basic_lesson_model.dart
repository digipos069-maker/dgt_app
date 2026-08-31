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
      id: (json['slug'] ?? json['id'])?.toString() ?? '',
      courseId: courseId,
      name: (json['title'] ?? json['name'])?.toString() ?? '',
      thumbnail: (json['videoThumbnail'] ?? json['thumbnail'])?.toString() ?? '',
      description: (json['description'] ?? json['desc'])?.toString() ?? '',
      durationLabel:
          (json['durationLabel'] ?? json['duration'])?.toString() ?? '10:00', // Default since API lacks it
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
  const BasicLessonBundle({
    required this.course,
    required this.lessons,
    this.page = 1,
    this.hasMore = false,
    this.isFetchingMore = false,
  });

  final BasicCourseModel course;
  final List<BasicLessonModel> lessons;
  final int page;
  final bool hasMore;
  final bool isFetchingMore;

  BasicLessonBundle copyWith({
    BasicCourseModel? course,
    List<BasicLessonModel>? lessons,
    int? page,
    bool? hasMore,
    bool? isFetchingMore,
  }) {
    return BasicLessonBundle(
      course: course ?? this.course,
      lessons: lessons ?? this.lessons,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      isFetchingMore: isFetchingMore ?? this.isFetchingMore,
    );
  }
}
