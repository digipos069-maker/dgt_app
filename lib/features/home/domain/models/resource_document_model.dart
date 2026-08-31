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
  });

  factory ResourceDocumentModel.fromJson(Map<String, dynamic> json) {
    final subject = json['subject'] as Map<String, dynamic>?;
    final typeStr = json['fileUrl']?.toString().toLowerCase() ?? '';
    final type = typeStr.endsWith('.pdf') ? ResourceDocumentType.pdf : ResourceDocumentType.video;
    
    return ResourceDocumentModel(
      id: json['id']?.toString() ?? '',
      year: json['year'] as int? ?? 0,
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      subjectId: json['subjectId']?.toString() ?? '',
      subjectName: (subject?['nameKm'] ?? subject?['nameEn'])?.toString() ?? '',
      type: type,
      sourceUrl: json['fileUrl']?.toString() ?? '',
      pageCount: 0,
      durationLabel: '',
    );
  }

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
}

class ResourceDocumentBundle {
  const ResourceDocumentBundle({
    required this.exam,
    required this.year,
    required this.subjects,
    required this.documents,
    this.page = 1,
    this.hasMore = false,
    this.isFetchingMore = false,
  });

  final ExamResourceModel exam;
  final int year;
  final List<ResourceSubjectModel> subjects;
  final List<ResourceDocumentModel> documents;
  final int page;
  final bool hasMore;
  final bool isFetchingMore;

  ResourceDocumentBundle copyWith({
    ExamResourceModel? exam,
    int? year,
    List<ResourceSubjectModel>? subjects,
    List<ResourceDocumentModel>? documents,
    int? page,
    bool? hasMore,
    bool? isFetchingMore,
  }) {
    return ResourceDocumentBundle(
      exam: exam ?? this.exam,
      year: year ?? this.year,
      subjects: subjects ?? this.subjects,
      documents: documents ?? this.documents,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      isFetchingMore: isFetchingMore ?? this.isFetchingMore,
    );
  }
}
