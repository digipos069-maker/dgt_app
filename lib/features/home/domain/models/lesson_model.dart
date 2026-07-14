import 'package:flutter/material.dart';

enum LessonType { video, reading, locked }

class LessonModel {
  const LessonModel({
    required this.id,
    required this.titleKey,
    required this.type,
    required this.durationMinutes,
    required this.isCompleted,
  });

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
