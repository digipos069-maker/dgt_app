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
    required String token,
    required String languageCode,
  }) async {
    final apiResources = await apiService.fetchExamTypes(token: token);
    
    final isKhmer = languageCode == 'km';
    final staticResources = [
      ExamResourceModel(
        id: 'outstanding-student',
        examName: isKhmer ? 'ប្រលងសិស្សពូកែ' : 'Outstanding Student Exam',
        icon: 'trophy',
        shortDescription: isKhmer ? 'វិញ្ញាសាប្រឡងសិស្សពូកែថ្នាក់ជាតិ' : 'National outstanding student exams',
      ),
      ExamResourceModel(
        id: 'study-document',
        examName: isKhmer ? 'ឯកសារសិក្សា' : 'Document for study',
        icon: 'book',
        shortDescription: isKhmer ? 'ឯកសារមេរៀន និងលំហាត់សម្រាប់សិក្សា' : 'Study materials and exercises',
      ),
    ];

    return [...apiResources, ...staticResources];
  }

  Future<ResourceYearBundle> fetchResourceYears({
    required String token,
    required String examId,
    required String languageCode,
  }) async {
    final resources = await fetchResources(token: token, languageCode: languageCode);
    final exam = _findExam(resources, examId);

    return ResourceYearBundle(
      exam: exam,
      years: List<ResourceYearModel>.generate(
        (DateTime.now().year - 2009), // Generates years down to 2010
        (index) => ResourceYearModel(
          year: DateTime.now().year - index,
          resourceCount: 12 - (index % 7),
        ),
        growable: false,
      ),
    );
  }

  Future<ResourceDocumentBundle> fetchResourcesByYear({
    required String token,
    required String examId,
    required int year,
    required String languageCode,
    String? subjectId,
    int page = 1,
  }) async {
    final resources = await fetchResources(token: token, languageCode: languageCode);
    final exam = _findExam(resources, examId);
    
    // For static exam types that don't exist in backend DB, we might want to map their IDs
    // But since user's API returns `examType: { id: 4, name: ... }`, we assume examId maps directly 
    // to examTypeId, unless it's a string like 'study-document'. If it's a non-numeric string, 
    // we just pass it to API (API might handle slug or we return empty if error).
    
    final jsonResponse = await apiService.fetchDocuments(
      token: token,
      examTypeId: examId,
      year: year,
      subjectId: subjectId,
      page: page,
      limit: 10,
    );

    final data = jsonResponse['data'] as List<dynamic>? ?? [];
    final meta = jsonResponse['meta'] as Map<String, dynamic>? ?? {};
    
    final documents = data.map((e) => ResourceDocumentModel.fromJson(e as Map<String, dynamic>)).toList();
    
    final subjectsSet = <String>{};
    final subjects = <ResourceSubjectModel>[];
    for (final doc in documents) {
      if (subjectsSet.add(doc.subjectId)) {
        subjects.add(ResourceSubjectModel(id: doc.subjectId, name: doc.subjectName));
      }
    }

    final totalPages = meta['totalPages'] as int? ?? 1;
    final hasMore = page < totalPages;

    return ResourceDocumentBundle(
      exam: exam,
      year: year,
      subjects: subjects,
      documents: documents,
      page: page,
      hasMore: hasMore,
    );
  }

  ExamResourceModel _findExam(
    List<ExamResourceModel> resources,
    String examId,
  ) {
    return resources.firstWhere(
      (resource) => resource.id == examId,
      orElse: () => throw StateError('Unknown exam resource: $examId'),
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
