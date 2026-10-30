/// A lesson (tutorial) attached to a tutor chat as context.
class AiTutorLessonRef {
  const AiTutorLessonRef({
    required this.id,
    required this.title,
    this.chapter,
    this.grade,
    this.subjectKm,
    this.subjectEn,
  });

  factory AiTutorLessonRef.fromJson(Map<String, dynamic> json) {
    final subject = json['subject'];
    return AiTutorLessonRef(
      id: (json['id'] as num).toInt(),
      title: (json['title'] ?? '').toString(),
      chapter: json['chapter']?.toString(),
      grade: json['grade'] is num ? (json['grade'] as num).toInt() : null,
      subjectKm: subject is Map ? subject['nameKm']?.toString() : null,
      subjectEn: subject is Map ? subject['nameEn']?.toString() : null,
    );
  }

  final int id;
  final String title;
  final String? chapter;
  final int? grade;
  final String? subjectKm;
  final String? subjectEn;

  String? subjectName(String languageCode) =>
      languageCode == 'km' ? (subjectKm ?? subjectEn) : (subjectEn ?? subjectKm);

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is AiTutorLessonRef && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

class AiTutorLessonSearchResult {
  const AiTutorLessonSearchResult({required this.lessons, required this.gradeFiltered});

  factory AiTutorLessonSearchResult.fromJson(Object? json) {
    if (json is! Map<String, dynamic>) {
      throw const FormatException('Invalid lessons response');
    }
    final data = json['data'];
    return AiTutorLessonSearchResult(
      gradeFiltered: json['gradeFiltered'] == true,
      lessons: data is List
          ? data
                .whereType<Map<String, dynamic>>()
                .where((item) => item['id'] is num)
                .map(AiTutorLessonRef.fromJson)
                .toList(growable: false)
          : const [],
    );
  }

  final List<AiTutorLessonRef> lessons;

  /// True when results were limited to the student's own grade.
  final bool gradeFiltered;
}

/// Parameters for the lesson picker search.
class AiTutorLessonQuery {
  const AiTutorLessonQuery({this.query = '', this.allGrades = false});

  final String query;
  final bool allGrades;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AiTutorLessonQuery && other.query == query && other.allGrades == allGrades;

  @override
  int get hashCode => Object.hash(query, allGrades);
}
