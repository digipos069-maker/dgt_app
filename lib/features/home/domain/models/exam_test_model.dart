import 'quiz_by_lesson_model.dart';
import 'quiz_models.dart';

/// One exam test ("ប្រឡងតេស្ត") from `GET /api/m/exam-tests`.
///
/// Sample item:
/// ```json
/// { "id": 11, "title": "...", "description": null, "track": "វិទ្យាសាស្ត្រពិត",
///   "durationMinutes": 60, "passingScore": 50, "totalScore": 100,
///   "examType": null, "subject": {"id":1,"nameKm":"...","nameEn":"..."},
///   "grade": {"id":7,"number":7}, "quizCount": 10, "totalPoints": 10 }
/// ```
class ExamTestModel {
  const ExamTestModel({
    required this.id,
    required this.title,
    this.description = '',
    this.track = '',
    this.examTypeName = '',
    this.subject,
    this.grade,
    this.durationMinutes = 0,
    this.passingScore = 0,
    this.totalScore = 0,
    this.quizCount = 0,
    this.totalPoints = 0,
    this.isLocked = false,
  });

  factory ExamTestModel.fromJson(Map<String, dynamic> json) {
    final examType = json['examType'];
    return ExamTestModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      track: json['track']?.toString() ?? '',
      examTypeName: examType is Map<String, dynamic>
          ? (examType['name'] ?? examType['nameKm'] ?? examType['nameEn'])
                    ?.toString() ??
                ''
          : '',
      subject: json['subject'] is Map<String, dynamic>
          ? QuizSubjectInfo.fromJson(json['subject'] as Map<String, dynamic>)
          : null,
      grade: json['grade'] is Map<String, dynamic>
          ? QuizGradeInfo.fromJson(json['grade'] as Map<String, dynamic>)
          : null,
      durationMinutes: _readInt(json['durationMinutes']),
      passingScore: _readInt(json['passingScore']),
      totalScore: _readInt(json['totalScore']),
      quizCount: _readInt(json['quizCount']),
      totalPoints: _readInt(json['totalPoints']),
      isLocked: json['isLocked'] == true,
    );
  }

  final String id;
  final String title;
  final String description;
  final String track;
  final String examTypeName;
  final QuizSubjectInfo? subject;
  final QuizGradeInfo? grade;
  final int durationMinutes;

  /// Minimum score (out of [totalScore]) needed to pass.
  final int passingScore;
  final int totalScore;
  final int quizCount;

  /// Sum of every quiz's `points`.
  final int totalPoints;

  /// Not returned by the API yet; kept for future subscription gating.
  final bool isLocked;

  String subjectName(String languageCode) =>
      subject?.localizedName(languageCode) ?? '';
}

/// A page of exam tests plus pagination info from `meta`.
class ExamTestPage {
  const ExamTestPage({
    required this.tests,
    required this.total,
    required this.page,
    required this.hasNextPage,
    this.isFetchingMore = false,
  });

  factory ExamTestPage.fromJson(Map<String, dynamic> json) {
    final tests = (json['data'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(ExamTestModel.fromJson)
        .toList();
    final meta = json['meta'] as Map<String, dynamic>? ?? const {};

    return ExamTestPage(
      tests: tests,
      total: meta.containsKey('total') ? _readInt(meta['total']) : tests.length,
      page: meta.containsKey('page') ? _readInt(meta['page']) : 1,
      hasNextPage: meta['hasNextPage'] == true,
    );
  }

  final List<ExamTestModel> tests;
  final int total;
  final int page;
  final bool hasNextPage;
  final bool isFetchingMore;

  ExamTestPage copyWith({
    List<ExamTestModel>? tests,
    int? total,
    int? page,
    bool? hasNextPage,
    bool? isFetchingMore,
  }) {
    return ExamTestPage(
      tests: tests ?? this.tests,
      total: total ?? this.total,
      page: page ?? this.page,
      hasNextPage: hasNextPage ?? this.hasNextPage,
      isFetchingMore: isFetchingMore ?? this.isFetchingMore,
    );
  }
}

/// One question inside a test, with the points it is worth.
class ExamTestQuestion {
  const ExamTestQuestion({
    required this.question,
    required this.points,
    required this.orderId,
  });

  factory ExamTestQuestion.fromJson(Map<String, dynamic> json) {
    final points = _readInt(json['points']);
    return ExamTestQuestion(
      question: QuizQuestionModel.fromJson(json),
      points: points <= 0 ? 1 : points,
      orderId: _readInt(json['orderId']),
    );
  }

  final QuizQuestionModel question;
  final int points;
  final int orderId;
}

/// `GET /api/m/exam-tests/:id` → `{ data: { ...ExamTestModel, quizzes: [...] } }`
class ExamTestDetail {
  const ExamTestDetail({required this.test, required this.questions});

  factory ExamTestDetail.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : json;
    final questions =
        (data['quizzes'] as List<dynamic>? ?? const [])
            .whereType<Map<String, dynamic>>()
            .map(ExamTestQuestion.fromJson)
            .toList()
          ..sort((a, b) => a.orderId.compareTo(b.orderId));

    return ExamTestDetail(
      test: ExamTestModel.fromJson(data),
      questions: questions,
    );
  }

  final ExamTestModel test;
  final List<ExamTestQuestion> questions;

  int get totalPoints => questions.fold(0, (sum, q) => sum + q.points);
}

int _readInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse('${value ?? ''}') ?? 0;
}
