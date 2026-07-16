import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/models/exam_resource_model.dart';

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
