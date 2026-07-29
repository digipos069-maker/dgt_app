import 'exam_resource_model.dart';

enum ResourceDocumentType {
  pdf,
  video;

  String get label => switch (this) {
    ResourceDocumentType.pdf => 'PDF',
    ResourceDocumentType.video => 'Video',
  };
}

class ResourceSubjectModel {
  const ResourceSubjectModel({required this.id, required this.name});

  final String id;
  final String name;
}

class ResourceDocumentModel {
  const ResourceDocumentModel({
    required this.id,
    required this.year,
    required this.title,
    required this.description,
    required this.subjectId,
    required this.subjectName,
    required this.type,
    required this.sourceUrl,
    required this.pageCount,
    required this.durationLabel,
    required this.isLocked,
  });

  final String id;
  final int year;
  final String title;
  final String description;
  final String subjectId;
  final String subjectName;
  final ResourceDocumentType type;
  final String sourceUrl;
  final int pageCount;
  final String durationLabel;
  final bool isLocked;
}

class ResourceDocumentBundle {
  const ResourceDocumentBundle({
    required this.exam,
    required this.year,
    required this.subjects,
    required this.documents,
  });

  final ExamResourceModel exam;
  final int year;
  final List<ResourceSubjectModel> subjects;
  final List<ResourceDocumentModel> documents;
}
