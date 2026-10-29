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

/// Response of `POST /api/m/exam-tests/:id/submit` (graded on the server).
class ExamTestSubmitResult {
  const ExamTestSubmitResult({
    required this.attemptId,
    required this.score,
    required this.totalScore,
    required this.passingScore,
    required this.passed,
    required this.earnedPoints,
    required this.totalPoints,
    required this.correctCount,
    required this.answeredCount,
    required this.questionCount,
    required this.isLate,
    required this.results,
  });

  factory ExamTestSubmitResult.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : json;
    final rawResults = data['results'] as List<dynamic>? ?? const [];
    final results = <int, ExamTestQuizResult>{};
    for (final item in rawResults.whereType<Map<String, dynamic>>()) {
      final r = ExamTestQuizResult.fromJson(item);
      results[r.quizId] = r;
    }
    final score = data['score'];

    return ExamTestSubmitResult(
      attemptId: _readInt(data['attemptId']),
      score: score is num ? score.toDouble() : double.tryParse('$score') ?? 0,
      totalScore: _readInt(data['totalScore']),
      passingScore: _readInt(data['passingScore']),
      passed: data['passed'] == true,
      earnedPoints: _readInt(data['earnedPoints']),
      totalPoints: _readInt(data['totalPoints']),
      correctCount: _readInt(data['correctCount']),
      answeredCount: _readInt(data['answeredCount']),
      questionCount: _readInt(data['questionCount']),
      isLate: data['isLate'] == true,
      results: results,
    );
  }

  final int attemptId;
  final double score;
  final int totalScore;
  final int passingScore;
  final bool passed;
  final int earnedPoints;
  final int totalPoints;
  final int correctCount;
  final int answeredCount;
  final int questionCount;
  final bool isLate;

  /// Keyed by quiz id.
  final Map<int, ExamTestQuizResult> results;
}

class ExamTestQuizResult {
  const ExamTestQuizResult({
    required this.quizId,
    required this.answered,
    required this.isCorrect,
    this.correctAnswer,
  });

  factory ExamTestQuizResult.fromJson(Map<String, dynamic> json) {
    return ExamTestQuizResult(
      quizId: _readInt(json['quizId']),
      answered: json['answered'] == true,
      isCorrect: json['isCorrect'] == true,
      correctAnswer: json['correctAnswer'],
    );
  }

  final int quizId;
  final bool answered;
  final bool isCorrect;

  /// String for choice / drag-and-drop, map for matching.
  final Object? correctAnswer;
}

/// One saved result from `GET /api/m/exam-test-attempts`.
class ExamTestAttemptModel {
  const ExamTestAttemptModel({
    required this.id,
    required this.examTestId,
    required this.title,
    required this.score,
    required this.totalScore,
    required this.passingScore,
    required this.passed,
    required this.scorePercent,
    required this.correctCount,
    required this.answeredCount,
    required this.questionCount,
    this.durationSeconds,
    this.submittedAt,
    this.subject,
    this.grade,
    this.track = '',
  });

  factory ExamTestAttemptModel.fromJson(Map<String, dynamic> json) {
    final test = json['examTest'] is Map<String, dynamic>
        ? json['examTest'] as Map<String, dynamic>
        : const <String, dynamic>{};
    double readDouble(Object? v) =>
        v is num ? v.toDouble() : double.tryParse('${v ?? ''}') ?? 0;

    return ExamTestAttemptModel(
      id: _readInt(json['id']),
      examTestId: _readInt(json['examTestId'] ?? test['id']),
      title: test['title']?.toString() ?? '',
      score: readDouble(json['score']),
      totalScore: _readInt(json['totalScore']),
      passingScore: _readInt(json['passingScore']),
      passed: json['passed'] == true,
      scorePercent: readDouble(json['scorePercent']),
      correctCount: _readInt(json['correctCount']),
      answeredCount: _readInt(json['answeredCount']),
      questionCount: _readInt(json['questionCount']),
      durationSeconds: json['durationSeconds'] == null
          ? null
          : _readInt(json['durationSeconds']),
      submittedAt: DateTime.tryParse(
        json['submittedAt']?.toString() ?? '',
      )?.toLocal(),
      subject: test['subject'] is Map<String, dynamic>
          ? QuizSubjectInfo.fromJson(test['subject'] as Map<String, dynamic>)
          : null,
      grade: test['grade'] is Map<String, dynamic>
          ? QuizGradeInfo.fromJson(test['grade'] as Map<String, dynamic>)
          : null,
      track: test['track']?.toString() ?? '',
    );
  }

  final int id;
  final int examTestId;
  final String title;
  final double score;
  final int totalScore;
  final int passingScore;
  final bool passed;
  final double scorePercent;
  final int correctCount;
  final int answeredCount;
  final int questionCount;
  final int? durationSeconds;
  final DateTime? submittedAt;
  final QuizSubjectInfo? subject;
  final QuizGradeInfo? grade;
  final String track;
}

class ExamTestAttemptSummary {
  const ExamTestAttemptSummary({
    this.totalAttempts = 0,
    this.testsTaken = 0,
    this.passedCount = 0,
    this.averageScorePercent = 0,
    this.bestScorePercent = 0,
  });

  factory ExamTestAttemptSummary.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const ExamTestAttemptSummary();
    double readDouble(Object? v) =>
        v is num ? v.toDouble() : double.tryParse('${v ?? ''}') ?? 0;
    return ExamTestAttemptSummary(
      totalAttempts: _readInt(json['totalAttempts']),
      testsTaken: _readInt(json['testsTaken']),
      passedCount: _readInt(json['passedCount']),
      averageScorePercent: readDouble(json['averageScorePercent']),
      bestScorePercent: readDouble(json['bestScorePercent']),
    );
  }

  final int totalAttempts;
  final int testsTaken;
  final int passedCount;
  final double averageScorePercent;
  final double bestScorePercent;
}

class ExamTestAttemptPage {
  const ExamTestAttemptPage({
    required this.attempts,
    required this.summary,
    required this.page,
    required this.hasNextPage,
    this.isFetchingMore = false,
  });

  factory ExamTestAttemptPage.fromJson(Map<String, dynamic> json) {
    final meta = json['meta'] as Map<String, dynamic>? ?? const {};
    return ExamTestAttemptPage(
      attempts: (json['data'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(ExamTestAttemptModel.fromJson)
          .toList(),
      summary: ExamTestAttemptSummary.fromJson(
        json['summary'] as Map<String, dynamic>?,
      ),
      page: meta.containsKey('page') ? _readInt(meta['page']) : 1,
      hasNextPage: meta['hasNextPage'] == true,
    );
  }

  final List<ExamTestAttemptModel> attempts;
  final ExamTestAttemptSummary summary;
  final int page;
  final bool hasNextPage;
  final bool isFetchingMore;

  ExamTestAttemptPage copyWith({
    List<ExamTestAttemptModel>? attempts,
    ExamTestAttemptSummary? summary,
    int? page,
    bool? hasNextPage,
    bool? isFetchingMore,
  }) {
    return ExamTestAttemptPage(
      attempts: attempts ?? this.attempts,
      summary: summary ?? this.summary,
      page: page ?? this.page,
      hasNextPage: hasNextPage ?? this.hasNextPage,
      isFetchingMore: isFetchingMore ?? this.isFetchingMore,
    );
  }
}

int _readInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse('${value ?? ''}') ?? 0;
}
