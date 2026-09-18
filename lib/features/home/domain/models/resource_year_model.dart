import 'exam_resource_model.dart';

class ResourceYearModel {
  const ResourceYearModel({
    required this.year,
    required this.resourceCount,
    this.examTypes = const [],
  });

  factory ResourceYearModel.fromJson(Map<String, dynamic> json) {
    final rawExamTypes = (json['examTypes'] ?? json['data']) as List<dynamic>? ?? [];
    final examTypes = rawExamTypes
        .whereType<Map<String, dynamic>>()
        .map(ExamTypeCountModel.fromJson)
        .toList();

    return ResourceYearModel(
      year: json['year'] as int? ?? int.tryParse('${json['year']}') ?? 0,
      resourceCount: json['total'] as int? ?? int.tryParse('${json['total']}') ?? 0,
      examTypes: examTypes,
    );
  }

  final int year;
  final int resourceCount;
  final List<ExamTypeCountModel> examTypes;
}

class ExamTypeCountModel {
  const ExamTypeCountModel({
    required this.id,
    required this.name,
    this.description = '',
    this.useTrack = false,
    this.total = 0,
    this.totalDocuments = 0,
  });

  factory ExamTypeCountModel.fromJson(Map<String, dynamic> json) {
    return ExamTypeCountModel(
      id: json['id'] as int? ?? int.tryParse('${json['id']}') ?? 0,
      name: (json['name'] ?? json['examName'])?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      useTrack: json['useTrack'] as bool? ?? false,
      total: json['total'] as int? ?? int.tryParse('${json['total']}') ?? 0,
      totalDocuments: json['totalDocuments'] as int? ??
          int.tryParse('${json['totalDocuments']}') ??
          (json['total'] as int? ?? 0),
    );
  }

  final int id;
  final String name;
  final String description;
  final bool useTrack;
  final int total;
  final int totalDocuments;
}

class ResourceYearBreakdownModel {
  const ResourceYearBreakdownModel({
    required this.year,
    required this.total,
    this.examTypes = const [],
  });

  factory ResourceYearBreakdownModel.fromJson(Map<String, dynamic> json) {
    final rawExamTypes = (json['examTypes'] ?? json['data']) as List<dynamic>? ?? [];
    return ResourceYearBreakdownModel(
      year: json['year'] as int? ?? int.tryParse('${json['year']}') ?? 0,
      total: json['total'] as int? ?? int.tryParse('${json['total']}') ?? 0,
      examTypes: rawExamTypes
          .whereType<Map<String, dynamic>>()
          .map(ExamTypeCountModel.fromJson)
          .toList(),
    );
  }

  final int year;
  final int total;
  final List<ExamTypeCountModel> examTypes;
}

class ResourceYearBundle {
  const ResourceYearBundle({required this.exam, required this.years});

  final ExamResourceModel exam;
  final List<ResourceYearModel> years;
}

