import 'package:flutter/material.dart';

enum LessonType { video, reading, locked }

class LessonModel {
  const LessonModel({
    required this.courseId,
    required this.id,
    required this.titleKey,
    required this.type,
    required this.durationMinutes,
    required this.isCompleted,
  });

  final String courseId;
  final String id;
  final String titleKey;
  final LessonType type;
  final int durationMinutes;
  final bool isCompleted;

  IconData get icon {
    return switch (type) {
      LessonType.video => Icons.play_arrow,
      LessonType.reading => Icons.description_outlined,
      LessonType.locked => Icons.lock_outline,
    };
  }
}

class CourseLessonBundle {
  const CourseLessonBundle({
    required this.courseId,
    required this.appBarTitleKey,
    required this.titleKey,
    required this.descriptionKey,
    required this.lessons,
  });

  final String courseId;
  final String appBarTitleKey;
  final String titleKey;
  final String descriptionKey;
  final List<LessonModel> lessons;
}

class LessonDetailModel {
  const LessonDetailModel({
    required this.courseId,
    required this.lessonId,
    required this.titleKey,
    required this.subjectKey,
    required this.moduleKey,
    required this.descriptionKey,
    required this.durationLabel,
    required this.quizTitleKey,
    required this.quizSubtitleKey,
    required this.questions,
  });

  final String courseId;
  final String lessonId;
  final String titleKey;
  final String subjectKey;
  final String moduleKey;
  final String descriptionKey;
  final String durationLabel;
  final String quizTitleKey;
  final String quizSubtitleKey;
  final List<QuizQuestionModel> questions;
}

class QuizQuestionModel {
  const QuizQuestionModel({
    required this.id,
    required this.questionKey,
    required this.options,
  });

  final String id;
  final String questionKey;
  final List<QuizOptionModel> options;
}

class QuizOptionModel {
  const QuizOptionModel({required this.id, required this.labelKey});

  final String id;
  final String labelKey;
}
