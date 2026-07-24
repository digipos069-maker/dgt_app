class QuizSubmissionResult {
  const QuizSubmissionResult({
    required this.message,
    required this.isCorrect,
    required this.correctAnswer,
  });

  factory QuizSubmissionResult.fromJson(Object? value) {
    final root = value is Map<String, dynamic>
        ? value
        : const <String, dynamic>{};
    final nested = root['data'];
    final data = nested is Map<String, dynamic> ? nested : root;

    return QuizSubmissionResult(
      message: _readMessage(data, root),
      isCorrect: _readCorrectness(data, root),
      correctAnswer: _readCorrectAnswer(data, root),
    );
  }

  final String message;
  final bool? isCorrect;
  final String correctAnswer;

  static String _readMessage(
    Map<String, dynamic> data,
    Map<String, dynamic> root,
  ) {
    for (final value in [
      data['message'],
      data['resultMessage'],
      root['message'],
    ]) {
      if (value is String && value.trim().isNotEmpty) {
        return value.trim();
      }
    }
    return '';
  }

  static bool? _readCorrectness(
    Map<String, dynamic> data,
    Map<String, dynamic> root,
  ) {
    for (final value in [
      data['isCorrect'],
      data['isCorrectAnswer'],
      data['correct'],
      data['result'],
      root['isCorrect'],
      root['isCorrectAnswer'],
      root['correct'],
      root['result'],
    ]) {
      if (value is bool) return value;
      if (value is num) return value != 0;
      if (value is String) {
        if (value.toLowerCase() == 'true') return true;
        if (value.toLowerCase() == 'false') return false;
      }
    }
    return null;
  }

  static String _readCorrectAnswer(
    Map<String, dynamic> data,
    Map<String, dynamic> root,
  ) {
    for (final value in [data['correctAnswer'], root['correctAnswer']]) {
      if (value is String && value.trim().isNotEmpty) {
        return value.trim();
      }
    }
    return '';
  }
}
