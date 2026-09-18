import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/models/exam_resource_model.dart';
import '../domain/models/resource_document_model.dart';
import '../domain/models/resource_year_model.dart';

import 'resource_api_service.dart';

final resourceRepositoryProvider = Provider<ResourceRepository>((ref) {
  return ResourceRepository(apiService: ref.watch(resourceApiServiceProvider));
});

class ResourceRepository {
  const ResourceRepository({required this.apiService});

  final ResourceApiService apiService;

  Future<List<ExamResourceModel>> fetchResources({
    String? token,
    required String languageCode,
  }) async {
    try {
      final apiResources = await apiService.fetchExamTypes(token: token);
      if (apiResources.isNotEmpty) {
        return apiResources;
      }
    } catch (_) {}

    // Fallback to /api/m/resource-by-year examTypes
    try {
      final breakdownJson = await apiService.fetchResourceByYear(token: token);
      final rawExamTypes = (breakdownJson['examTypes'] ?? breakdownJson['data']) as List<dynamic>? ?? [];
      if (rawExamTypes.isNotEmpty) {
        return rawExamTypes
            .whereType<Map<String, dynamic>>()
            .map(ExamResourceModel.fromJson)
            .toList();
      }
    } catch (_) {}

    final isKhmer = languageCode == 'km';
    final mockList = isKhmer ? _khmerMockData : _englishMockData;
    return mockList.map((e) => ExamResourceModel.fromJson(e)).toList();
  }

  Future<ResourceYearBundle> fetchResourceYears({
    String? token,
    required String examId,
    required String languageCode,
  }) async {
    final resources = await fetchResources(token: token, languageCode: languageCode);
    final exam = _findExam(resources, examId);
    final parsedExamId = int.tryParse(examId);

    try {
      final json = await apiService.fetchResourceByYear(token: token);
      final rawYears = (json['years'] ?? json['data']) as List<dynamic>? ?? [];

      if (rawYears.isNotEmpty) {
        final years = <ResourceYearModel>[];

        for (final item in rawYears) {
          if (item is! Map<String, dynamic>) continue;
          final yearNum = item['year'] as int? ?? int.tryParse('${item['year']}') ?? 0;
          if (yearNum == 0) continue;

          int count = 0;
          final examTypes = (item['examTypes'] ?? item['data']) as List<dynamic>? ?? [];
          if (parsedExamId != null) {
            for (final et in examTypes) {
              if (et is Map<String, dynamic>) {
                final etId = et['id'] as int? ?? int.tryParse('${et['id']}');
                if (etId == parsedExamId) {
                  count = et['total'] as int? ??
                      et['totalDocuments'] as int? ??
                      int.tryParse('${et['total'] ?? et['totalDocuments']}') ??
                      0;
                  break;
                }
              }
            }
          } else {
            count = item['total'] as int? ?? int.tryParse('${item['total']}') ?? 0;
          }

          years.add(ResourceYearModel(year: yearNum, resourceCount: count));
        }

        if (years.isNotEmpty) {
          years.sort((a, b) => b.year.compareTo(a.year));
          return ResourceYearBundle(exam: exam, years: years);
        }
      }
    } catch (_) {}

    // Fallback if network is offline or no years returned
    return ResourceYearBundle(
      exam: exam,
      years: List<ResourceYearModel>.generate(
        (DateTime.now().year - 2014),
        (index) => ResourceYearModel(
          year: DateTime.now().year - index,
          resourceCount: 0,
        ),
        growable: false,
      ),
    );
  }

  Future<ResourceDocumentBundle> fetchResourcesByYear({
    String? token,
    required String examId,
    required int year,
    required String languageCode,
    String? subjectId,
    String? search,
    int page = 1,
    int limit = 10,
  }) async {
    final resources = await fetchResources(token: token, languageCode: languageCode);
    final exam = _findExam(resources, examId);
    final parsedExamId = int.tryParse(examId);
    final parsedSubjectId = subjectId != null ? int.tryParse(subjectId) : null;

    final jsonResponse = await apiService.fetchMobileResources(
      token: token,
      year: year,
      examTypeId: parsedExamId,
      subjectId: parsedSubjectId,
      search: search,
      page: page,
      limit: limit,
    );

    final data = jsonResponse['data'] as List<dynamic>? ?? [];
    final metaJson = jsonResponse['meta'] as Map<String, dynamic>?;
    final meta = ResourcePaginationMeta.fromJson(metaJson);

    final documents = data
        .whereType<Map<String, dynamic>>()
        .map(ResourceDocumentModel.fromJson)
        .toList();

    final subjectsSet = <String>{};
    final subjects = <ResourceSubjectModel>[];
    for (final doc in documents) {
      if (doc.subjectId.isNotEmpty && subjectsSet.add(doc.subjectId)) {
        subjects.add(ResourceSubjectModel(id: doc.subjectId, name: doc.subjectName));
      }
    }

    return ResourceDocumentBundle(
      exam: exam,
      year: year,
      subjects: subjects,
      documents: documents,
      page: meta.page,
      hasMore: meta.hasNextPage,
      meta: meta,
    );
  }

  ExamResourceModel _findExam(
    List<ExamResourceModel> resources,
    String examId,
  ) {
    return resources.firstWhere(
      (resource) => resource.id == examId,
      orElse: () => ExamResourceModel(
        id: examId,
        examName: 'Exam $examId',
        icon: 'exam',
        shortDescription: '',
      ),
    );
  }



  // Replace these maps with decoded API response data when the endpoint is ready.
  static const _englishMockData = <Map<String, dynamic>>[
    {
      'id': 'outstanding-student',
      'examName': 'Outstanding Student Exam',
      'icon': 'trophy',
      'isLocked': false,
      'shortDescription':
          'Practice advanced subject questions for the national outstanding student competition.',
    },
    {
      'id': 'medical-entrance',
      'examName': 'Medical Entrance Exam',
      'icon': 'medical',
      'isLocked': true,
      'shortDescription':
          'Prepare for medical school entrance tests with science-focused practice sets.',
    },
    {
      'id': 'teacher-recruitment',
      'examName': 'Teacher Recruitment Exam',
      'icon': 'teacher',
      'isLocked': false,
      'shortDescription':
          'Review teaching knowledge, general education, and previous recruitment questions.',
    },
    {
      'id': 'techno-entrance',
      'examName': 'Techno Entrance Exam',
      'icon': 'engineering',
      'isLocked': true,
      'shortDescription':
          'Build mathematics and physics skills for technology institute entrance exams.',
    },
    {
      'id': 'bac-ii',
      'examName': 'BAC II Exam',
      'icon': 'certificate',
      'isLocked': false,
      'shortDescription':
          'Study past BAC II questions and structured revision materials by subject.',
    },
  ];

  static const _khmerMockData = <Map<String, dynamic>>[
    {
      'id': 'outstanding-student',
      'examName': 'ប្រឡងសិស្សពូកែ',
      'icon': 'trophy',
      'isLocked': false,
      'shortDescription':
          'ហ្វឹកហាត់សំណួរកម្រិតខ្ពស់សម្រាប់ការប្រកួតសិស្សពូកែថ្នាក់ជាតិ។',
    },
    {
      'id': 'medical-entrance',
      'examName': 'ប្រឡងពេទ្យ',
      'icon': 'medical',
      'isLocked': true,
      'shortDescription':
          'ត្រៀមប្រឡងចូលសាលាពេទ្យជាមួយលំហាត់ផ្តោតលើមុខវិជ្ជាវិទ្យាសាស្ត្រ។',
    },
    {
      'id': 'teacher-recruitment',
      'examName': 'ប្រឡងគ្រូ',
      'icon': 'teacher',
      'isLocked': false,
      'shortDescription':
          'រំលឹកចំណេះដឹងគរុកោសល្យ ចំណេះដឹងទូទៅ និងវិញ្ញាសាប្រឡងពីមុន។',
    },
    {
      'id': 'techno-entrance',
      'examName': 'ប្រឡងតិចណូ',
      'icon': 'engineering',
      'isLocked': true,
      'shortDescription':
          'ពង្រឹងគណិតវិទ្យា និងរូបវិទ្យាសម្រាប់ការប្រឡងចូលវិទ្យាស្ថានបច្ចេកវិទ្យា។',
    },
    {
      'id': 'bac-ii',
      'examName': 'ប្រឡង BAC II',
      'icon': 'certificate',
      'isLocked': false,
      'shortDescription':
          'សិក្សាវិញ្ញាសា BAC II ឆ្នាំមុន និងឯកសាររំលឹកមេរៀនតាមមុខវិជ្ជា។',
    },
  ];
}
