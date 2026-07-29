import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/models/exam_resource_model.dart';
import '../domain/models/resource_document_model.dart';
import '../domain/models/resource_year_model.dart';

final resourceRepositoryProvider = Provider<ResourceRepository>((ref) {
  return const ResourceRepository();
});

class ResourceRepository {
  const ResourceRepository();

  Future<List<ExamResourceModel>> fetchResources({
    required String languageCode,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));

    final data = languageCode == 'km' ? _khmerMockData : _englishMockData;
    return data.map(ExamResourceModel.fromJson).toList(growable: false);
  }

  Future<ResourceYearBundle> fetchResourceYears({
    required String examId,
    required String languageCode,
  }) async {
    final resources = await fetchResources(languageCode: languageCode);
    final exam = _findExam(resources, examId);

    return ResourceYearBundle(
      exam: exam,
      years: List<ResourceYearModel>.generate(
        16,
        (index) => ResourceYearModel(
          year: 2025 - index,
          resourceCount: 12 - (index % 7),
        ),
        growable: false,
      ),
    );
  }

  Future<ResourceDocumentBundle> fetchResourcesByYear({
    required String examId,
    required int year,
    required String languageCode,
  }) async {
    final resources = await fetchResources(languageCode: languageCode);
    final exam = _findExam(resources, examId);
    final isKhmer = languageCode == 'km';
    final subjects = isKhmer ? _khmerSubjects : _englishSubjects;
    final documents = _buildDocuments(
      examId: examId,
      year: year,
      isKhmer: isKhmer,
      subjects: subjects,
    );

    return ResourceDocumentBundle(
      exam: exam,
      year: year,
      subjects: subjects,
      documents: documents,
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

  List<ResourceDocumentModel> _buildDocuments({
    required String examId,
    required int year,
    required bool isKhmer,
    required List<ResourceSubjectModel> subjects,
  }) {
    final titles = isKhmer
        ? const [
            'វិញ្ញាសាហ្វឹកហាត់ពេញលេញ',
            'សំណួរត្រៀមប្រឡង',
            'វិញ្ញាសា និងចម្លើយ',
            'មេរៀនសង្ខេបសម្រាប់រំលឹក',
            'លំហាត់អនុវត្តកម្រិតខ្ពស់',
          ]
        : const [
            'Complete practice paper',
            'Exam preparation questions',
            'Past paper with solutions',
            'Quick revision notes',
            'Advanced practice exercises',
          ];
    final descriptions = isKhmer
        ? const [
            'អនុវត្តតាមទម្រង់វិញ្ញាសាប្រឡងជាក់ស្តែង។',
            'ពង្រឹងជំនាញសំខាន់ៗជាមួយសំណួរជ្រើសរើស។',
            'ពិនិត្យវិធីដោះស្រាយ និងចម្លើយលម្អិត។',
            'រំលឹកគោលគំនិត និងរូបមន្តសំខាន់ៗ។',
            'សាកល្បងសមត្ថភាពជាមួយលំហាត់ពិបាកៗ។',
          ]
        : const [
            'Practice with a paper structured like the official exam.',
            'Strengthen key skills with a focused question set.',
            'Review worked methods and detailed answers.',
            'Refresh important concepts and formulas.',
            'Challenge yourself with higher-level exercises.',
          ];

    return List<ResourceDocumentModel>.generate(titles.length, (index) {
      final subject = subjects[index % subjects.length];
      return ResourceDocumentModel(
        id: '$examId-$year-${index + 1}',
        title: '${titles[index]} $year',
        description: descriptions[index],
        subjectId: subject.id,
        subjectName: subject.name,
        fileType: index.isEven ? 'PDF' : 'Worksheet',
        isLocked: index == titles.length - 1,
      );
    }, growable: false);
  }

  static const _englishSubjects = <ResourceSubjectModel>[
    ResourceSubjectModel(id: 'mathematics', name: 'Mathematics'),
    ResourceSubjectModel(id: 'physics', name: 'Physics'),
    ResourceSubjectModel(id: 'chemistry', name: 'Chemistry'),
    ResourceSubjectModel(id: 'biology', name: 'Biology'),
  ];

  static const _khmerSubjects = <ResourceSubjectModel>[
    ResourceSubjectModel(id: 'mathematics', name: 'គណិតវិទ្យា'),
    ResourceSubjectModel(id: 'physics', name: 'រូបវិទ្យា'),
    ResourceSubjectModel(id: 'chemistry', name: 'គីមីវិទ្យា'),
    ResourceSubjectModel(id: 'biology', name: 'ជីវវិទ្យា'),
  ];

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
