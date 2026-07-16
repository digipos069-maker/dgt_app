import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/models/basic_course_model.dart';

final basicCourseRepositoryProvider = Provider<BasicCourseRepository>((ref) {
  return const BasicCourseRepository();
});

class BasicCourseRepository {
  const BasicCourseRepository();

  Future<List<BasicCourseModel>> fetchBasicCourses({
    required String languageCode,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));

    final data = languageCode == 'km' ? _khmerMockData : _englishMockData;
    return data.map(BasicCourseModel.fromJson).toList(growable: false);
  }

  // Replace these maps with decoded API response data when the endpoint is ready.
  static const _englishMockData = <Map<String, dynamic>>[
    {
      'id': 'mathematics',
      'name': 'Mathematics',
      'thumbnail':
          'https://images.unsplash.com/photo-1635070041078-e363dbe005cb?auto=format&fit=crop&w=1200&q=80',
      'description':
          'Build strong foundations in numbers, algebra, geometry, and problem solving.',
    },
    {
      'id': 'physics',
      'name': 'Physics',
      'thumbnail':
          'https://images.unsplash.com/photo-1636466497217-26a8cbeaf0aa?auto=format&fit=crop&w=1200&q=80',
      'description':
          'Understand motion, forces, energy, and the physical laws behind everyday life.',
    },
    {
      'id': 'chemistry',
      'name': 'Chemistry',
      'thumbnail':
          'https://images.unsplash.com/photo-1532094349884-543bc11b234d?auto=format&fit=crop&w=1200&q=80',
      'description':
          'Explore matter, atoms, chemical reactions, and laboratory fundamentals.',
    },
    {
      'id': 'biology',
      'name': 'Biology',
      'thumbnail':
          'https://images.unsplash.com/photo-1530026405186-ed1f139313f8?auto=format&fit=crop&w=1200&q=80',
      'description':
          'Learn about cells, living systems, genetics, ecology, and human biology.',
    },
  ];

  static const _khmerMockData = <Map<String, dynamic>>[
    {
      'id': 'mathematics',
      'name': 'គណិតវិទ្យា',
      'thumbnail':
          'https://images.unsplash.com/photo-1635070041078-e363dbe005cb?auto=format&fit=crop&w=1200&q=80',
      'description':
          'ពង្រឹងមូលដ្ឋានគ្រឹះអំពីចំនួន ពិជគណិត ធរណីមាត្រ និងការដោះស្រាយលំហាត់។',
    },
    {
      'id': 'physics',
      'name': 'រូបវិទ្យា',
      'thumbnail':
          'https://images.unsplash.com/photo-1636466497217-26a8cbeaf0aa?auto=format&fit=crop&w=1200&q=80',
      'description':
          'ស្វែងយល់អំពីចលនា កម្លាំង ថាមពល និងច្បាប់រូបវិទ្យាក្នុងជីវិតប្រចាំថ្ងៃ។',
    },
    {
      'id': 'chemistry',
      'name': 'គីមីវិទ្យា',
      'thumbnail':
          'https://images.unsplash.com/photo-1532094349884-543bc11b234d?auto=format&fit=crop&w=1200&q=80',
      'description':
          'សិក្សាអំពីរូបធាតុ អាតូម ប្រតិកម្មគីមី និងមូលដ្ឋានគ្រឹះនៃមន្ទីរពិសោធន៍។',
    },
    {
      'id': 'biology',
      'name': 'ជីវវិទ្យា',
      'thumbnail':
          'https://images.unsplash.com/photo-1530026405186-ed1f139313f8?auto=format&fit=crop&w=1200&q=80',
      'description':
          'សិក្សាអំពីកោសិកា ប្រព័ន្ធរស់ ពន្ធុវិទ្យា អេកូឡូស៊ី និងជីវវិទ្យាមនុស្ស។',
    },
  ];
}
