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

    final quizzesJson = value['quizzes'];
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
      quizzes: quizzesJson is List
          ? quizzesJson
                .map(TutorialQuizModel.tryParse)
                .whereType<TutorialQuizModel>()
                .toList(growable: false)
          : const [],
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

    final quizData = value['quizData'];
    final options = quizData is Map<String, dynamic>
        ? quizData['options']
        : null;
    return TutorialQuizModel(
      id: _readInt(value['id']),
      question: _readString(value['question']),
      options: options is List
          ? options
                .map(_readString)
                .where((option) => option.isNotEmpty)
                .toList(growable: false)
          : const [],
      correctAnswer: quizData is Map<String, dynamic>
          ? _readString(quizData['correct'])
          : '',
    );
  }

  final int id;
  final String question;
  final List<String> options;
  final String correctAnswer;
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
