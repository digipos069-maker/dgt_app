import 'exam_resource_model.dart';

class ResourceSubjectModel {
  const ResourceSubjectModel({required this.id, required this.name});

  final String id;
  final String name;
}

class ResourceDocumentModel {
  const ResourceDocumentModel({
    required this.id,
    required this.title,
    required this.description,
    required this.subjectId,
    required this.subjectName,
    required this.fileType,
    required this.isLocked,
  });

  final String id;
  final String title;
  final String description;
  final String subjectId;
  final String subjectName;
  final String fileType;
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
