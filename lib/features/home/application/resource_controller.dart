import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/resource_repository.dart';
import '../domain/models/exam_resource_model.dart';
import '../domain/models/resource_document_model.dart';
import '../domain/models/resource_year_model.dart';

final examResourcesProvider = FutureProvider.autoDispose
    .family<List<ExamResourceModel>, String>((ref, languageCode) {
      return ref
          .watch(resourceRepositoryProvider)
          .fetchResources(languageCode: languageCode);
    });

class ResourceYearsRequest {
  const ResourceYearsRequest({
    required this.examId,
    required this.languageCode,
  });

  final String examId;
  final String languageCode;

  @override
  bool operator ==(Object other) =>
      other is ResourceYearsRequest &&
      other.examId == examId &&
      other.languageCode == languageCode;

  @override
  int get hashCode => Object.hash(examId, languageCode);
}

final resourceYearsProvider = FutureProvider.autoDispose
    .family<ResourceYearBundle, ResourceYearsRequest>((ref, request) {
      return ref
          .watch(resourceRepositoryProvider)
          .fetchResourceYears(
            examId: request.examId,
            languageCode: request.languageCode,
          );
    });

class ResourcesByYearRequest {
  const ResourcesByYearRequest({
    required this.examId,
    required this.year,
    required this.languageCode,
  });

  final String examId;
  final int year;
  final String languageCode;

  @override
  bool operator ==(Object other) =>
      other is ResourcesByYearRequest &&
      other.examId == examId &&
      other.year == year &&
      other.languageCode == languageCode;

  @override
  int get hashCode => Object.hash(examId, year, languageCode);
}

final resourcesByYearProvider = FutureProvider.autoDispose
    .family<ResourceDocumentBundle, ResourcesByYearRequest>((ref, request) {
      return ref
          .watch(resourceRepositoryProvider)
          .fetchResourcesByYear(
            examId: request.examId,
            year: request.year,
            languageCode: request.languageCode,
          );
    });
