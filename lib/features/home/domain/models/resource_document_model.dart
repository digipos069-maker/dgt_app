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
    this.examTypeId,
    this.examTypeName,
  });

  factory ResourceDocumentModel.fromJson(Map<String, dynamic> json) {
    final subject = json['subject'] as Map<String, dynamic>?;
    final examType = json['examType'] as Map<String, dynamic>?;
    final fileUrl = (json['fileUrl'] ?? json['sourceUrl'] ?? '')?.toString() ?? '';
    final typeStr = fileUrl.toLowerCase();
    final type = (typeStr.endsWith('.mp4') || typeStr.endsWith('.mov') || typeStr.contains('video'))
        ? ResourceDocumentType.video
        : ResourceDocumentType.pdf;

    return ResourceDocumentModel(
      id: json['id']?.toString() ?? '',
      year: json['year'] as int? ?? int.tryParse('${json['year']}') ?? 0,
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      subjectId: (json['subjectId'] ?? json['subject_id'] ?? subject?['id'])?.toString() ?? '',
      subjectName: (subject?['nameKm'] ?? subject?['nameEn'] ?? subject?['name'] ?? json['subjectName'])?.toString() ?? '',
      type: type,
      sourceUrl: fileUrl,
      pageCount: json['pageCount'] as int? ?? int.tryParse('${json['pageCount']}') ?? 0,
      durationLabel: json['durationLabel']?.toString() ?? '',
      examTypeId: json['examTypeId'] as int? ?? json['exam_type_id'] as int? ?? int.tryParse('${json['examTypeId'] ?? json['exam_type_id']}'),
      examTypeName: (examType?['name'] ?? json['examTypeName'])?.toString(),
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
  final int? examTypeId;
  final String? examTypeName;
}

class ResourcePaginationMeta {
  const ResourcePaginationMeta({
    this.total = 0,
    this.page = 1,
    this.limit = 10,
    this.totalPages = 1,
    this.hasNextPage = false,
    this.hasPreviousPage = false,
  });

  factory ResourcePaginationMeta.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const ResourcePaginationMeta();
    final total = json['total'] as int? ?? int.tryParse('${json['total']}') ?? 0;
    final page = json['page'] as int? ?? int.tryParse('${json['page']}') ?? 1;
    final limit = json['limit'] as int? ?? int.tryParse('${json['limit']}') ?? 10;
    final totalPages = json['totalPages'] as int? ?? int.tryParse('${json['totalPages']}') ?? 1;
    final hasNextPage = json['hasNextPage'] as bool? ?? (page < totalPages);
    final hasPreviousPage = json['hasPreviousPage'] as bool? ?? (page > 1);

    return ResourcePaginationMeta(
      total: total,
      page: page,
      limit: limit,
      totalPages: totalPages,
      hasNextPage: hasNextPage,
      hasPreviousPage: hasPreviousPage,
    );
  }

  final int total;
  final int page;
  final int limit;
  final int totalPages;
  final bool hasNextPage;
  final bool hasPreviousPage;
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
    this.meta = const ResourcePaginationMeta(),
  });

  final ExamResourceModel exam;
  final int year;
  final List<ResourceSubjectModel> subjects;
  final List<ResourceDocumentModel> documents;
  final int page;
  final bool hasMore;
  final bool isFetchingMore;
  final ResourcePaginationMeta meta;

  ResourceDocumentBundle copyWith({
    ExamResourceModel? exam,
    int? year,
    List<ResourceSubjectModel>? subjects,
    List<ResourceDocumentModel>? documents,
    int? page,
    bool? hasMore,
    bool? isFetchingMore,
    ResourcePaginationMeta? meta,
  }) {
    return ResourceDocumentBundle(
      exam: exam ?? this.exam,
      year: year ?? this.year,
      subjects: subjects ?? this.subjects,
      documents: documents ?? this.documents,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      isFetchingMore: isFetchingMore ?? this.isFetchingMore,
      meta: meta ?? this.meta,
    );
  }
}
