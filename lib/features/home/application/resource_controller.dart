import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/application/auth_controller.dart';
import '../data/resource_repository.dart';
import '../domain/models/exam_resource_model.dart';
import '../domain/models/resource_document_model.dart';
import '../domain/models/resource_year_model.dart';

final examResourcesProvider = FutureProvider.autoDispose
    .family<List<ExamResourceModel>, String>((ref, languageCode) async {
      final authState = ref.watch(authControllerProvider);
      final user = switch (authState) {
        AsyncData(:final value) => value,
        _ => null,
      };
      final token = user?.token;
      if (token == null || token.isEmpty) throw Exception('Unauthorized');

      return await ref
          .watch(resourceRepositoryProvider)
          .fetchResources(token: token, languageCode: languageCode);
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
    .family<ResourceYearBundle, ResourceYearsRequest>((ref, request) async {
      final authState = ref.watch(authControllerProvider);
      final user = switch (authState) {
        AsyncData(:final value) => value,
        _ => null,
      };
      final token = user?.token;
      if (token == null || token.isEmpty) throw Exception('Unauthorized');

      return await ref
          .watch(resourceRepositoryProvider)
          .fetchResourceYears(
            token: token,
            examId: request.examId,
            languageCode: request.languageCode,
          );
    });

class ResourcesByYearRequest {
  const ResourcesByYearRequest({
    required this.examId,
    required this.year,
    required this.languageCode,
    this.subjectId,
  });

  final String examId;
  final int year;
  final String languageCode;
  final String? subjectId;

  @override
  bool operator ==(Object other) =>
      other is ResourcesByYearRequest &&
      other.examId == examId &&
      other.year == year &&
      other.languageCode == languageCode &&
      other.subjectId == subjectId;

  @override
  int get hashCode => Object.hash(examId, year, languageCode, subjectId);
}

class ResourcesByYearNotifier extends AsyncNotifier<ResourceDocumentBundle> {
  ResourcesByYearNotifier(this.arg);
  
  final ResourcesByYearRequest arg;

  @override
  Future<ResourceDocumentBundle> build() async {
    return _fetchPage(1);
  }

  Future<ResourceDocumentBundle> _fetchPage(int page) async {
    final authState = ref.watch(authControllerProvider);
    final user = switch (authState) {
      AsyncData(:final value) => value,
      _ => null,
    };
    final token = user?.token;
    if (token == null || token.isEmpty) throw Exception('Unauthorized');

    return await ref.read(resourceRepositoryProvider).fetchResourcesByYear(
      token: token,
      examId: arg.examId,
      year: arg.year,
      languageCode: arg.languageCode,
      subjectId: arg.subjectId,
      page: page,
    );
  }

  Future<void> loadMore() async {
    final currentBundle = state.value;
    if (currentBundle == null || !currentBundle.hasMore || state.isLoading || currentBundle.isFetchingMore) return;

    state = AsyncData(currentBundle.copyWith(isFetchingMore: true));
    try {
      final newBundle = await _fetchPage(currentBundle.page + 1);
      
      final mergedDocs = [...currentBundle.documents, ...newBundle.documents];
      
      // Preserve existing subjects, and add any new ones
      final subjectSet = <String>{for (final s in currentBundle.subjects) s.id};
      final mergedSubjects = List<ResourceSubjectModel>.from(currentBundle.subjects);
      
      for (final doc in newBundle.documents) {
        if (subjectSet.add(doc.subjectId)) {
          mergedSubjects.add(ResourceSubjectModel(id: doc.subjectId, name: doc.subjectName));
        }
      }

      state = AsyncData(currentBundle.copyWith(
        documents: mergedDocs,
        subjects: mergedSubjects,
        page: newBundle.page,
        hasMore: newBundle.hasMore,
        isFetchingMore: false,
      ));
    } catch (e, st) {
      state = AsyncData(currentBundle.copyWith(isFetchingMore: false)); // Revert fetching state
      // We don't throw to avoid wiping out the existing list, but ideally we'd show a snackbar
    }
  }
}

final resourcesByYearProvider = AsyncNotifierProvider.autoDispose
    .family<ResourcesByYearNotifier, ResourceDocumentBundle, ResourcesByYearRequest>(
  (arg) => ResourcesByYearNotifier(arg),
);
