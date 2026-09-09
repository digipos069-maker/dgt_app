import 'dart:convert';

enum QuizType {
  multipleChoice,
  matching,
  dragAndDrop,
}

class QuizStem {
  const QuizStem({required this.id, required this.text});

  factory QuizStem.fromJson(Map<String, dynamic> json) {
    return QuizStem(
      id: json['id']?.toString() ?? '',
      text: json['text']?.toString() ?? '',
    );
  }

  final String id;
  final String text;

  Map<String, dynamic> toJson() => {'id': id, 'text': text};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuizStem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          text == other.text;

  @override
  int get hashCode => id.hashCode ^ text.hashCode;
}

class MatchingOption {
  const MatchingOption({required this.id, required this.text});

  factory MatchingOption.fromJson(Map<String, dynamic> json) {
    return MatchingOption(
      id: json['id']?.toString() ?? '',
      text: json['text']?.toString() ?? '',
    );
  }

  final String id;
  final String text;

  Map<String, dynamic> toJson() => {'id': id, 'text': text};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MatchingOption &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          text == other.text;

  @override
  int get hashCode => id.hashCode ^ text.hashCode;
}

class MatchingQuizData {
  const MatchingQuizData({
    required this.stems,
    required this.options,
    required this.description,
    this.correctMatches = const <String, String>{},
  });

  factory MatchingQuizData.fromJson(Map<String, dynamic> json) {
    final stemsList = (json['stems'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(QuizStem.fromJson)
        .toList();

    final optionsList = (json['options'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(MatchingOption.fromJson)
        .toList();

    final matchesRaw = json['correctMatches'] as Map<String, dynamic>? ?? {};
    final correctMatches = matchesRaw.map(
      (key, value) => MapEntry(key.toString(), value.toString()),
    );

    return MatchingQuizData(
      stems: stemsList,
      options: optionsList,
      description: json['description']?.toString() ?? '',
      correctMatches: correctMatches,
    );
  }

  final List<QuizStem> stems;
  final List<MatchingOption> options;
  final String description;
  final Map<String, String> correctMatches;

  bool isMatchCorrect(String stemId, String optionId) {
    return correctMatches[stemId] == optionId;
  }

  bool areAllMatchesCorrect(Map<String, String> userMatches) {
    if (userMatches.length != stems.length) return false;
    for (final stem in stems) {
      if (userMatches[stem.id] != correctMatches[stem.id]) {
        return false;
      }
    }
    return true;
  }

  Map<String, dynamic> toJson() => {
    'stems': stems.map((s) => s.toJson()).toList(),
    'options': options.map((o) => o.toJson()).toList(),
    'description': description,
    'correctMatches': correctMatches,
  };
}

class DragAndDropQuizData {
  const DragAndDropQuizData({
    required this.correct,
    required this.draggables,
    required this.droppableId,
    this.prompt = '',
  });

  factory DragAndDropQuizData.fromJson(Map<String, dynamic> json) {
    final draggablesList = (json['draggables'] as List<dynamic>? ?? const [])
        .map((e) => e.toString())
        .toList();

    return DragAndDropQuizData(
      correct: json['correct']?.toString() ?? '',
      draggables: draggablesList,
      droppableId: json['droppableId']?.toString() ?? '',
      prompt: json['prompt']?.toString() ?? '',
    );
  }

  final String correct;
  final List<String> draggables;
  final String droppableId;
  final String prompt;

  bool isCorrect(String answer) {
    return answer.trim() == correct.trim();
  }

  Map<String, dynamic> toJson() => {
    'correct': correct,
    'draggables': draggables,
    'droppableId': droppableId,
    if (prompt.isNotEmpty) 'prompt': prompt,
  };
}

class QuizOptionModel {
  const QuizOptionModel({required this.id, required this.labelKey});

  factory QuizOptionModel.fromJson(Map<String, dynamic> json) {
    return QuizOptionModel(
      id: json['id']?.toString() ?? '',
      labelKey: (json['labelKey'] ?? json['text'] ?? json['label'] ?? '')
          .toString(),
    );
  }

  final String id;
  final String labelKey;

  Map<String, dynamic> toJson() => {'id': id, 'labelKey': labelKey};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuizOptionModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          labelKey == other.labelKey;

  @override
  int get hashCode => id.hashCode ^ labelKey.hashCode;
}

class QuizQuestionModel {
  const QuizQuestionModel({
    required this.id,
    required this.questionKey,
    this.options = const <QuizOptionModel>[],
    this.quizId,
    this.type = QuizType.multipleChoice,
    this.matchingData,
    this.dragAndDropData,
  });

  const QuizQuestionModel.multipleChoice({
    required this.id,
    required this.questionKey,
    required this.options,
    this.quizId,
  }) : type = QuizType.multipleChoice,
       matchingData = null,
       dragAndDropData = null;

  const QuizQuestionModel.matching({
    required this.id,
    required this.matchingData,
    this.questionKey = '',
    this.quizId,
  }) : type = QuizType.matching,
       options = const [],
       dragAndDropData = null;

  const QuizQuestionModel.dragAndDrop({
    required this.id,
    required this.dragAndDropData,
    this.questionKey = '',
    this.quizId,
  }) : type = QuizType.dragAndDrop,
       options = const [],
       matchingData = null;

  factory QuizQuestionModel.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic>? quizData;
    final rawQuizData = json['quizData'] ?? json['data'];
    if (rawQuizData is Map<String, dynamic>) {
      quizData = rawQuizData;
    } else if (rawQuizData is String && rawQuizData.trim().startsWith('{')) {
      try {
        final decoded = jsonDecode(rawQuizData);
        if (decoded is Map<String, dynamic>) quizData = decoded;
      } catch (_) {}
    }

    final typeString = (json['type'] ??
            json['quizType'] ??
            quizData?['type'] ??
            quizData?['quizType'])
        ?.toString()
        .toLowerCase() ??
        '';

    final quizType = switch (typeString) {
      'matching' || 'match' => QuizType.matching,
      'draganddrop' || 'drag_and_drop' || 'drag_drop' => QuizType.dragAndDrop,
      _ => QuizType.multipleChoice,
    };

    MatchingQuizData? matchingData;
    if (quizData != null &&
        quizData.containsKey('stems') &&
        quizData.containsKey('options')) {
      matchingData = MatchingQuizData.fromJson(quizData);
    } else if (json['matching'] is Map<String, dynamic>) {
      matchingData = MatchingQuizData.fromJson(
        json['matching'] as Map<String, dynamic>,
      );
    } else if (json.containsKey('stems') && json.containsKey('options')) {
      matchingData = MatchingQuizData.fromJson(json);
    }

    DragAndDropQuizData? dragAndDropData;
    if (quizData != null &&
        (quizData.containsKey('draggables') ||
            quizData.containsKey('droppableId'))) {
      dragAndDropData = DragAndDropQuizData.fromJson(quizData);
    } else if (json['dragAndDrop'] is Map<String, dynamic>) {
      dragAndDropData = DragAndDropQuizData.fromJson(
        json['dragAndDrop'] as Map<String, dynamic>,
      );
    } else if (json.containsKey('draggables') ||
        json.containsKey('droppableId')) {
      dragAndDropData = DragAndDropQuizData.fromJson(json);
    }

    final optionsRaw = (json['options'] ?? quizData?['options']) as List<dynamic>? ??
        const [];
    final options = <QuizOptionModel>[];
    for (final (index, item) in optionsRaw.indexed) {
      if (item is Map<String, dynamic>) {
        options.add(QuizOptionModel.fromJson(item));
      } else if (item != null) {
        options.add(
          QuizOptionModel(
            id: String.fromCharCode(65 + index),
            labelKey: item.toString(),
          ),
        );
      }
    }

    final rawQuizId = json['quizId'] ??
        json['quiz_id'] ??
        quizData?['quizId'] ??
        quizData?['quiz_id'] ??
        json['id'] ??
        quizData?['id'];
    final quizId = rawQuizId is int
        ? rawQuizId
        : int.tryParse(rawQuizId?.toString() ?? '');

    return QuizQuestionModel(
      id: json['id']?.toString() ?? '',
      quizId: quizId,
      questionKey: json['questionKey']?.toString() ??
          json['question']?.toString() ??
          quizData?['question']?.toString() ??
          quizData?['prompt']?.toString() ??
          '',
      type: matchingData != null
          ? QuizType.matching
          : dragAndDropData != null
              ? QuizType.dragAndDrop
              : quizType,
      options: options,
      matchingData: matchingData,
      dragAndDropData: dragAndDropData,
    );
  }

  final String id;
  final int? quizId;
  final String questionKey;
  final QuizType type;
  final List<QuizOptionModel> options;
  final MatchingQuizData? matchingData;
  final DragAndDropQuizData? dragAndDropData;
}
