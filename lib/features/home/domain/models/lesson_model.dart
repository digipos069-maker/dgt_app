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
    this.title,
    this.description = '',
    this.mainVideoUrl = '',
    this.videoThumbnail = '',
    this.slug = '',
    this.orderId = 0,
  });

  final String courseId;
  final String id;
  final String titleKey;
  final LessonType type;
  final int durationMinutes;
  final bool isCompleted;
  final String? title;
  final String description;
  final String mainVideoUrl;
  final String videoThumbnail;
  final String slug;
  final int orderId;

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
    this.page = 1,
    this.hasMore = false,
    this.isFetchingMore = false,
  });

  final String courseId;
  final String appBarTitleKey;
  final String titleKey;
  final String descriptionKey;
  final List<LessonModel> lessons;
  final int page;
  final bool hasMore;
  final bool isFetchingMore;

  CourseLessonBundle copyWith({
    String? courseId,
    String? appBarTitleKey,
    String? titleKey,
    String? descriptionKey,
    List<LessonModel>? lessons,
    int? page,
    bool? hasMore,
    bool? isFetchingMore,
  }) {
    return CourseLessonBundle(
      courseId: courseId ?? this.courseId,
      appBarTitleKey: appBarTitleKey ?? this.appBarTitleKey,
      titleKey: titleKey ?? this.titleKey,
      descriptionKey: descriptionKey ?? this.descriptionKey,
      lessons: lessons ?? this.lessons,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      isFetchingMore: isFetchingMore ?? this.isFetchingMore,
    );
  }
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
    this.mainVideoUrl = '',
    this.videoThumbnail = '',
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
  final String mainVideoUrl;
  final String videoThumbnail;
}

class QuizQuestionModel {
  const QuizQuestionModel({
    required this.id,
    required this.questionKey,
    required this.options,
    this.quizId,
  });

  final String id;
  final int? quizId;
  final String questionKey;
  final List<QuizOptionModel> options;
}

class QuizOptionModel {
  const QuizOptionModel({required this.id, required this.labelKey});

  final String id;
  final String labelKey;
}
