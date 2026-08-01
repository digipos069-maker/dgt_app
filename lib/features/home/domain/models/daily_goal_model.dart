class DailyGoalModel {
  const DailyGoalModel({
    required this.targetVideos,
    required this.targetQuizzes,
    required this.completedVideos,
    required this.completedQuizzes,
  });

  final int targetVideos;
  final int targetQuizzes;
  final int completedVideos;
  final int completedQuizzes;

  bool get isCompleted =>
      completedVideos >= targetVideos && completedQuizzes >= targetQuizzes;

  factory DailyGoalModel.fromJson(Map<String, dynamic> json) {
    return DailyGoalModel(
      targetVideos: json['targetVideos'] as int? ?? 3,
      targetQuizzes: json['targetQuizzes'] as int? ?? 15,
      completedVideos: json['completedVideos'] as int? ?? 0,
      completedQuizzes: json['completedQuizzes'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'targetVideos': targetVideos,
      'targetQuizzes': targetQuizzes,
      'completedVideos': completedVideos,
      'completedQuizzes': completedQuizzes,
    };
  }
}
