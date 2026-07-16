class LearningLessonModel {
  const LearningLessonModel({
    required this.id,
    required this.title,
    required this.description,
    required this.thumbnail,
    required this.subjectId,
    required this.gradeId,
    required this.durationMinutes,
    required this.rating,
    required this.learnerCount,
    required this.isLocked,
  });

  factory LearningLessonModel.fromJson(Object? value) {
    if (value is! Map<String, dynamic>) {
      throw const FormatException('Invalid lesson item');
    }

    final id = _readString(value, const ['id', 'lessonId', 'uuid']);
    final title = _readString(value, const [
      'title',
      'name',
      'lessonName',
      'titleKm',
      'titleKh',
    ]);

    return LearningLessonModel(
      id: id,
      title: title,
      description: _readString(value, const [
        'description',
        'desc',
        'shortDescription',
        'summary',
      ]),
      thumbnail: _readString(value, const [
        'thumbnail',
        'thumbnailUrl',
        'image',
        'imageUrl',
      ]),
      subjectId:
          _readInt(value['subjectId']) ??
          _readNestedInt(value['subject'], 'id'),
      gradeId:
          _readInt(value['gradeId']) ?? _readNestedInt(value['grade'], 'id'),
      durationMinutes:
          _readInt(value['durationMinutes']) ??
          _readInt(value['duration']) ??
          0,
      rating: _readDouble(value['rating']) ?? 0,
      learnerCount:
          _readInt(value['learnerCount']) ??
          _readInt(value['studentsCount']) ??
          _readInt(value['enrolledCount']) ??
          0,
      isLocked: value['isLocked'] == true || value['locked'] == true,
    );
  }

  final String id;
  final String title;
  final String description;
  final String thumbnail;
  final int? subjectId;
  final int? gradeId;
  final int durationMinutes;
  final double rating;
  final int learnerCount;
  final bool isLocked;

  static String _readString(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final text = json[key]?.toString().trim() ?? '';
      if (text.isNotEmpty && text != 'null') return text;
    }
    return '';
  }

  static int? _readNestedInt(Object? value, String key) {
    if (value is Map<String, dynamic>) return _readInt(value[key]);
    return null;
  }

  static int? _readInt(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '');
  }

  static double? _readDouble(Object? value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '');
  }
}
