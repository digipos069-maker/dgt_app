import 'quiz_models.dart';

class QuizSubjectInfo {
  const QuizSubjectInfo({
    required this.id,
    required this.nameKm,
    required this.nameEn,
  });

  factory QuizSubjectInfo.fromJson(Map<String, dynamic> json) {
    return QuizSubjectInfo(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      nameKm: json['nameKm']?.toString() ?? '',
      nameEn: json['nameEn']?.toString() ?? '',
    );
  }

  final int id;
  final String nameKm;
  final String nameEn;

  String localizedName(String languageCode) =>
      languageCode == 'km' ? (nameKm.isNotEmpty ? nameKm : nameEn) : (nameEn.isNotEmpty ? nameEn : nameKm);
}

class QuizGradeInfo {
  const QuizGradeInfo({
    required this.id,
    required this.number,
  });

  factory QuizGradeInfo.fromJson(Map<String, dynamic> json) {
    return QuizGradeInfo(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      number: json['number'] is int
          ? json['number'] as int
          : int.tryParse(json['number']?.toString() ?? '') ?? 0,
    );
  }

  final int id;
  final int number;
}

class QuizLessonInfo {
  const QuizLessonInfo({
    required this.id,
    required this.title,
    this.description = '',
    this.thumbnail = '',
    this.orderId = 0,
    this.trackType,
    this.subjectId,
    this.gradeId,
    this.subject,
    this.grade,
  });

  factory QuizLessonInfo.fromJson(Map<String, dynamic> json) {
    return QuizLessonInfo(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      thumbnail: json['thumbnail']?.toString() ?? '',
      orderId: json['orderId'] is int
          ? json['orderId'] as int
          : int.tryParse(json['orderId']?.toString() ?? '') ?? 0,
      trackType: json['trackType']?.toString() ?? json['track_type']?.toString(),
      subjectId: json['subjectId'] is int
          ? json['subjectId'] as int
          : int.tryParse(json['subjectId']?.toString() ?? ''),
      gradeId: json['gradeId'] is int
          ? json['gradeId'] as int
          : int.tryParse(json['gradeId']?.toString() ?? ''),
      subject: json['subject'] is Map<String, dynamic>
          ? QuizSubjectInfo.fromJson(json['subject'] as Map<String, dynamic>)
          : null,
      grade: json['grade'] is Map<String, dynamic>
          ? QuizGradeInfo.fromJson(json['grade'] as Map<String, dynamic>)
          : null,
    );
  }

  final int id;
  final String title;
  final String description;
  final String thumbnail;
  final int orderId;
  final String? trackType;
  final int? subjectId;
  final int? gradeId;
  final QuizSubjectInfo? subject;
  final QuizGradeInfo? grade;
}

class QuizByLessonResponse {
  const QuizByLessonResponse({
    required this.success,
    this.lesson,
    this.totalAvailable = 0,
    this.size = 15,
    this.count = 0,
    this.quizzes = const <QuizQuestionModel>[],
  });

  factory QuizByLessonResponse.fromJson(Map<String, dynamic> json) {
    final rawQuizzes = (json['quizzes'] ?? json['data']) as List<dynamic>? ??
        const [];
    final quizzes = rawQuizzes
        .whereType<Map<String, dynamic>>()
        .map(QuizQuestionModel.fromJson)
        .toList();

    return QuizByLessonResponse(
      success: json['success'] == true,
      lesson: json['lesson'] is Map<String, dynamic>
          ? QuizLessonInfo.fromJson(json['lesson'] as Map<String, dynamic>)
          : null,
      totalAvailable: json['totalAvailable'] is int
          ? json['totalAvailable'] as int
          : int.tryParse(json['totalAvailable']?.toString() ?? '') ?? quizzes.length,
      size: json['size'] is int
          ? json['size'] as int
          : int.tryParse(json['size']?.toString() ?? '') ?? 15,
      count: json['count'] is int
          ? json['count'] as int
          : int.tryParse(json['count']?.toString() ?? '') ?? quizzes.length,
      quizzes: quizzes,
    );
  }

  final bool success;
  final QuizLessonInfo? lesson;
  final int totalAvailable;
  final int size;
  final int count;
  final List<QuizQuestionModel> quizzes;
}
