import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/application/auth_controller.dart';
import '../data/resource_repository.dart';
import '../domain/models/exam_resource_model.dart';
import '../domain/models/exam_test_model.dart';
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

      return await ref
          .watch(resourceRepositoryProvider)
          .fetchResources(token: token, languageCode: languageCode);
    });

/// Paginated list of exam tests ("ប្រឡងតេស្ត").
class ExamTestsNotifier extends AsyncNotifier<ExamTestPage> {
  static const pageSize = 10;

  String? get _token {
    final authState = ref.read(authControllerProvider);
    return switch (authState) {
      AsyncData(:final value) => value?.token,
      _ => null,
    };
  }

  @override
  Future<ExamTestPage> build() {
    // Re-fetch when the user logs in or out.
    ref.watch(authControllerProvider.select((s) => s.value?.token));
    return ref
        .read(resourceRepositoryProvider)
        .fetchExamTests(token: _token, page: 1, limit: pageSize);
  }

  Future<void> loadMore() async {
    final current = state.value;
    if (current == null ||
        !current.hasNextPage ||
        current.isFetchingMore ||
        state.isLoading) {
      return;
    }

    state = AsyncData(current.copyWith(isFetchingMore: true));
    try {
      final next = await ref
          .read(resourceRepositoryProvider)
          .fetchExamTests(
            token: _token,
            page: current.page + 1,
            limit: pageSize,
          );
      state = AsyncData(
        next.copyWith(
          tests: [...current.tests, ...next.tests],
          isFetchingMore: false,
        ),
      );
    } catch (_) {
      state = AsyncData(current.copyWith(isFetchingMore: false));
    }
  }
}

// No automatic retry: on failure show the error + retry button right away
// instead of an endless loading skeleton while Riverpod retries.
Duration? _noRetry(int retryCount, Object error) => null;

final examTestsProvider =
    AsyncNotifierProvider.autoDispose<ExamTestsNotifier, ExamTestPage>(
      ExamTestsNotifier.new,
      retry: _noRetry,
    );

/// Thrown when "My study" is opened without a logged-in user.
class NotLoggedInException implements Exception {
  const NotLoggedInException();
}

/// Paginated list of the student's saved test results.
class MyExamTestAttemptsNotifier extends AsyncNotifier<ExamTestAttemptPage> {
  static const pageSize = 10;

  String? get _token {
    final authState = ref.read(authControllerProvider);
    return switch (authState) {
      AsyncData(:final value) => value?.token,
      _ => null,
    };
  }

  @override
  Future<ExamTestAttemptPage> build() {
    ref.watch(authControllerProvider.select((s) => s.value?.token));
    final token = _token;
    if (token == null || token.isEmpty) {
      throw const NotLoggedInException();
    }
    return ref
        .read(resourceRepositoryProvider)
        .fetchMyExamTestAttempts(token: token, page: 1, limit: pageSize);
  }

  Future<void> loadMore() async {
    final current = state.value;
    final token = _token;
    if (current == null ||
        token == null ||
        !current.hasNextPage ||
        current.isFetchingMore ||
        state.isLoading) {
      return;
    }

    state = AsyncData(current.copyWith(isFetchingMore: true));
    try {
      final next = await ref
          .read(resourceRepositoryProvider)
          .fetchMyExamTestAttempts(
            token: token,
            page: current.page + 1,
            limit: pageSize,
          );
      state = AsyncData(
        next.copyWith(
          attempts: [...current.attempts, ...next.attempts],
          isFetchingMore: false,
        ),
      );
    } catch (_) {
      state = AsyncData(current.copyWith(isFetchingMore: false));
    }
  }
}

final myExamTestAttemptsProvider =
    AsyncNotifierProvider.autoDispose<
      MyExamTestAttemptsNotifier,
      ExamTestAttemptPage
    >(MyExamTestAttemptsNotifier.new, retry: _noRetry);

final examTestDetailProvider = FutureProvider.autoDispose
    .family<ExamTestDetail, String>(retry: _noRetry, (ref, testId) async {
      final authState = ref.watch(authControllerProvider);
      final token = switch (authState) {
        AsyncData(:final value) => value?.token,
        _ => null,
      };

      return ref
          .watch(resourceRepositoryProvider)
          .fetchExamTestDetail(testId: testId, token: token);
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
    this.search,
  });

  final String examId;
  final int year;
  final String languageCode;
  final String? subjectId;
  final String? search;

  @override
  bool operator ==(Object other) =>
      other is ResourcesByYearRequest &&
      other.examId == examId &&
      other.year == year &&
      other.languageCode == languageCode &&
      other.subjectId == subjectId &&
      other.search == search;

  @override
  int get hashCode => Object.hash(examId, year, languageCode, subjectId, search);
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

    return await ref.read(resourceRepositoryProvider).fetchResourcesByYear(
      token: token,
      examId: arg.examId,
      year: arg.year,
      languageCode: arg.languageCode,
      subjectId: arg.subjectId,
      search: arg.search,
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
    } catch (_) {
      state = AsyncData(currentBundle.copyWith(isFetchingMore: false)); // Revert fetching state
      // We don't throw to avoid wiping out the existing list, but ideally we'd show a snackbar
    }
  }
}

final resourcesByYearProvider = AsyncNotifierProvider.autoDispose
    .family<ResourcesByYearNotifier, ResourceDocumentBundle, ResourcesByYearRequest>(
  (arg) => ResourcesByYearNotifier(arg),
);
