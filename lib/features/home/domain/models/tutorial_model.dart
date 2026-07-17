class TutorialModel {
  const TutorialModel({
    required this.id,
    required this.title,
    required this.slug,
    required this.description,
    required this.mainVideoUrl,
    required this.subjectId,
    required this.gradeId,
    required this.orderId,
    required this.lessonId,
    required this.videoThumbnail,
    required this.isLocked,
  });

  factory TutorialModel.fromJson(Object? value) {
    if (value is! Map<String, dynamic>) {
      throw const FormatException('Invalid tutorial item');
    }

    return TutorialModel(
      id: _readInt(value['id']),
      title: _readString(value['title']),
      slug: _readString(value['slug']),
      description: _readString(value['description']),
      mainVideoUrl: _readString(value['mainVideoUrl']),
      subjectId: _readInt(value['subjectId']),
      gradeId: _readInt(value['gradeId']),
      orderId: _readInt(value['orderId']),
      lessonId: _readInt(value['lessonId']),
      videoThumbnail: _readString(value['videoThumbnail']),
      isLocked: _readBool(value['lock']) || _readBool(value['isLocked']),
    );
  }

  final int id;
  final String title;
  final String slug;
  final String description;
  final String mainVideoUrl;
  final int subjectId;
  final int gradeId;
  final int orderId;
  final int lessonId;
  final String videoThumbnail;
  final bool isLocked;

  static String _readString(Object? value) {
    final text = value?.toString().trim() ?? '';
    return text == 'null' ? '' : text;
  }

  static int _readInt(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static bool _readBool(Object? value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    final text = value?.toString().toLowerCase();
    return text == 'true' || text == '1';
  }
}
