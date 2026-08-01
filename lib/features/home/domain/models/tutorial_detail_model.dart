import 'dart:convert';

class TutorialDetailModel {
  const TutorialDetailModel({
    required this.id,
    required this.title,
    required this.slug,
    required this.description,
    required this.mainVideoUrl,
    required this.videoThumbnail,
    required this.subjectId,
    required this.gradeId,
    required this.orderId,
    required this.lessonId,
    required this.quizzes,
  });

  factory TutorialDetailModel.fromJson(Object? value) {
    if (value is! Map<String, dynamic>) {
      throw const FormatException('Invalid tutorial detail');
    }

    final quizzesJson = value['quizzes'] ?? value['quiz'] ?? value['questions'];
    return TutorialDetailModel(
      id: _readInt(value['id']),
      title: _readString(value['title']),
      slug: _readString(value['slug']),
      description: _readString(value['description']),
      mainVideoUrl: _readString(value['mainVideoUrl']),
      videoThumbnail: _readString(value['videoThumbnail']),
      subjectId: _readInt(value['subjectId']),
      gradeId: _readInt(value['gradeId']),
      orderId: _readInt(value['orderId']),
      lessonId: _readInt(value['lessonId']),
      quizzes: _readQuizItems(quizzesJson)
          .map(TutorialQuizModel.tryParse)
          .whereType<TutorialQuizModel>()
          .toList(growable: false),
    );
  }

  final int id;
  final String title;
  final String slug;
  final String description;
  final String mainVideoUrl;
  final String videoThumbnail;
  final int subjectId;
  final int gradeId;
  final int orderId;
  final int lessonId;
  final List<TutorialQuizModel> quizzes;
}

class TutorialQuizModel {
  const TutorialQuizModel({
    required this.id,
    required this.question,
    required this.options,
    required this.correctAnswer,
  });

  static TutorialQuizModel? tryParse(Object? value) {
    if (value is! Map<String, dynamic>) return null;

    final quizData = _readMap(value['quizData']);
    final options = quizData?['options'] ?? value['options'];
    return TutorialQuizModel(
      id: _readInt(value['id'] ?? value['quizId'] ?? value['quiz_id'] ?? quizData?['id'] ?? quizData?['quizId'] ?? quizData?['quiz_id']),
      question: _readString(value['question'] ?? quizData?['question']),
      options: options is List
          ? options
                .map(_readString)
                .where((option) => option.isNotEmpty)
                .toList(growable: false)
          : const [],
      correctAnswer: _readString(
        quizData?['correct'] ??
            quizData?['correctAnswer'] ??
            value['correct'] ??
            value['correctAnswer'],
      ),
    );
  }

  final int id;
  final String question;
  final List<String> options;
  final String correctAnswer;
}

Iterable<Object?> _readQuizItems(Object? value) {
  if (value is List) return value;
  if (value is Map<String, dynamic>) {
    for (final key in const ['data', 'items', 'results', 'rows']) {
      final nested = value[key];
      if (nested is List) return nested;
    }
    return [value];
  }
  return const [];
}

Map<String, dynamic>? _readMap(Object? value) {
  if (value is Map<String, dynamic>) return value;
  if (value is String && value.trim().isNotEmpty) {
    try {
      final decoded = jsonDecode(value);
      return decoded is Map<String, dynamic> ? decoded : null;
    } on FormatException {
      return null;
    }
  }
  return null;
}

String _readString(Object? value) {
  final text = value?.toString().trim() ?? '';
  return text == 'null' ? '' : text;
}

int _readInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}
