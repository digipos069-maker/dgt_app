import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/models/basic_course_model.dart';
import '../domain/models/basic_lesson_model.dart';
import '../domain/models/lesson_model.dart';

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

  Future<BasicLessonBundle> fetchBasicLessons({
    required String courseId,
    required String languageCode,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));

    final courseData = _courseData(languageCode);
    final courseJson = courseData.firstWhere(
      (item) => item['id'] == courseId,
      orElse: () => courseData.first,
    );
    final resolvedCourseId = courseJson['id']!.toString();
    final lessonData = _lessonData(languageCode)[resolvedCourseId] ?? const [];

    return BasicLessonBundle(
      course: BasicCourseModel.fromJson(courseJson),
      lessons: lessonData
          .map(
            (item) =>
                BasicLessonModel.fromJson(item, courseId: resolvedCourseId),
          )
          .toList(growable: false),
    );
  }

  Future<LessonDetailModel> fetchBasicLessonDetail({
    required String courseId,
    required String lessonId,
    required String languageCode,
  }) async {
    final bundle = await fetchBasicLessons(
      courseId: courseId,
      languageCode: languageCode,
    );
    final lesson = bundle.lessons.firstWhere(
      (item) => item.id == lessonId,
      orElse: () => bundle.lessons.first,
    );
    final quiz = _quizData(languageCode)[bundle.course.id]!;
    final options = quiz['options']! as List<String>;
    final isKhmer = languageCode == 'km';

    return LessonDetailModel(
      courseId: bundle.course.id,
      lessonId: lesson.id,
      titleKey: lesson.name,
      subjectKey: bundle.course.name,
      moduleKey: isKhmer ? 'មេរៀនមូលដ្ឋាន' : 'Basic lesson',
      descriptionKey: lesson.description,
      durationLabel: lesson.durationLabel,
      quizTitleKey: isKhmer ? 'សំណួរមេរៀន' : 'Lesson quiz',
      quizSubtitleKey: isKhmer
          ? 'សាកល្បងការយល់ដឹងរបស់អ្នកអំពីមេរៀននេះ។'
          : 'Check your understanding of this basic lesson.',
      questions: [
        QuizQuestionModel(
          quizId: 1,
          id: 'q1',
          questionKey: quiz['question']! as String,
          options: [
            for (final (index, option) in options.indexed)
              QuizOptionModel(
                id: String.fromCharCode(65 + index),
                labelKey: option,
              ),
          ],
        ),
      ],
    );
  }

  List<Map<String, dynamic>> _courseData(String languageCode) {
    return languageCode == 'km' ? _khmerMockData : _englishMockData;
  }

  Map<String, List<Map<String, dynamic>>> _lessonData(String languageCode) {
    return languageCode == 'km' ? _khmerLessonMockData : _englishLessonMockData;
  }

  Map<String, Map<String, Object>> _quizData(String languageCode) {
    return languageCode == 'km' ? _khmerQuizMockData : _englishQuizMockData;
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

  static const _englishLessonMockData = <String, List<Map<String, dynamic>>>{
    'mathematics': [
      {
        'id': 'numbers-operations',
        'name': 'Numbers and operations',
        'thumbnail':
            'https://images.unsplash.com/photo-1635070041078-e363dbe005cb?auto=format&fit=crop&w=900&q=80',
        'description':
            'Review number types and build confidence with the four basic operations.',
        'duration': '12:30',
      },
      {
        'id': 'fractions-decimals',
        'name': 'Fractions and decimals',
        'thumbnail':
            'https://images.unsplash.com/photo-1635070041078-e363dbe005cb?auto=format&fit=crop&w=900&q=80',
        'description':
            'Convert, compare, add, and multiply fractions and decimal numbers.',
        'duration': '15:20',
      },
      {
        'id': 'intro-algebra',
        'name': 'Introduction to algebra',
        'thumbnail':
            'https://images.unsplash.com/photo-1635070041078-e363dbe005cb?auto=format&fit=crop&w=900&q=80',
        'description':
            'Use variables and simple expressions to represent everyday problems.',
        'duration': '18:10',
      },
    ],
    'physics': [
      {
        'id': 'measurement-units',
        'name': 'Measurement and units',
        'thumbnail':
            'https://images.unsplash.com/photo-1636466497217-26a8cbeaf0aa?auto=format&fit=crop&w=900&q=80',
        'description':
            'Learn standard units and how scientists measure physical quantities.',
        'duration': '11:45',
      },
      {
        'id': 'motion-speed',
        'name': 'Motion and speed',
        'thumbnail':
            'https://images.unsplash.com/photo-1636466497217-26a8cbeaf0aa?auto=format&fit=crop&w=900&q=80',
        'description':
            'Describe motion and calculate speed using distance and time.',
        'duration': '16:00',
      },
      {
        'id': 'forces',
        'name': 'Forces around us',
        'thumbnail':
            'https://images.unsplash.com/photo-1636466497217-26a8cbeaf0aa?auto=format&fit=crop&w=900&q=80',
        'description':
            'Explore pushes, pulls, gravity, friction, and balanced forces.',
        'duration': '17:35',
      },
    ],
    'chemistry': [
      {
        'id': 'matter-states',
        'name': 'Matter and its states',
        'thumbnail':
            'https://images.unsplash.com/photo-1532094349884-543bc11b234d?auto=format&fit=crop&w=900&q=80',
        'description':
            'Compare solids, liquids, and gases through particle behavior.',
        'duration': '13:15',
      },
      {
        'id': 'atoms-elements',
        'name': 'Atoms and elements',
        'thumbnail':
            'https://images.unsplash.com/photo-1532094349884-543bc11b234d?auto=format&fit=crop&w=900&q=80',
        'description':
            'Understand atoms and how elements are organized and identified.',
        'duration': '16:40',
      },
      {
        'id': 'simple-reactions',
        'name': 'Simple chemical reactions',
        'thumbnail':
            'https://images.unsplash.com/photo-1532094349884-543bc11b234d?auto=format&fit=crop&w=900&q=80',
        'description':
            'Recognize reactants, products, and evidence of chemical change.',
        'duration': '19:05',
      },
    ],
    'biology': [
      {
        'id': 'living-things',
        'name': 'Characteristics of life',
        'thumbnail':
            'https://images.unsplash.com/photo-1530026405186-ed1f139313f8?auto=format&fit=crop&w=900&q=80',
        'description':
            'Identify the shared characteristics that define living organisms.',
        'duration': '12:10',
      },
      {
        'id': 'cells',
        'name': 'Introduction to cells',
        'thumbnail':
            'https://images.unsplash.com/photo-1530026405186-ed1f139313f8?auto=format&fit=crop&w=900&q=80',
        'description':
            'Discover cell structures and compare plant and animal cells.',
        'duration': '17:20',
      },
      {
        'id': 'ecosystems',
        'name': 'Ecosystems and food chains',
        'thumbnail':
            'https://images.unsplash.com/photo-1530026405186-ed1f139313f8?auto=format&fit=crop&w=900&q=80',
        'description':
            'See how energy moves through organisms and their environment.',
        'duration': '18:30',
      },
    ],
  };

  static const _khmerLessonMockData = <String, List<Map<String, dynamic>>>{
    'mathematics': [
      {
        'id': 'numbers-operations',
        'name': 'ចំនួន និងប្រមាណវិធី',
        'thumbnail':
            'https://images.unsplash.com/photo-1635070041078-e363dbe005cb?auto=format&fit=crop&w=900&q=80',
        'description': 'រំលឹកប្រភេទចំនួន និងអនុវត្តប្រមាណវិធីគ្រឹះទាំងបួន។',
        'duration': '12:30',
      },
      {
        'id': 'fractions-decimals',
        'name': 'ប្រភាគ និងទសភាគ',
        'thumbnail':
            'https://images.unsplash.com/photo-1635070041078-e363dbe005cb?auto=format&fit=crop&w=900&q=80',
        'description': 'បម្លែង ប្រៀបធៀប បូក និងគុណប្រភាគនិងចំនួនទសភាគ។',
        'duration': '15:20',
      },
      {
        'id': 'intro-algebra',
        'name': 'សេចក្តីផ្តើមពិជគណិត',
        'thumbnail':
            'https://images.unsplash.com/photo-1635070041078-e363dbe005cb?auto=format&fit=crop&w=900&q=80',
        'description': 'ប្រើអថេរ និងកន្សោមសាមញ្ញសម្រាប់បញ្ហាប្រចាំថ្ងៃ។',
        'duration': '18:10',
      },
    ],
    'physics': [
      {
        'id': 'measurement-units',
        'name': 'រង្វាស់ និងឯកតា',
        'thumbnail':
            'https://images.unsplash.com/photo-1636466497217-26a8cbeaf0aa?auto=format&fit=crop&w=900&q=80',
        'description': 'សិក្សាឯកតាស្តង់ដារ និងការវាស់បរិមាណរូបវិទ្យា។',
        'duration': '11:45',
      },
      {
        'id': 'motion-speed',
        'name': 'ចលនា និងល្បឿន',
        'thumbnail':
            'https://images.unsplash.com/photo-1636466497217-26a8cbeaf0aa?auto=format&fit=crop&w=900&q=80',
        'description': 'ពិពណ៌នាចលនា និងគណនាល្បឿនតាមចម្ងាយនិងពេលវេលា។',
        'duration': '16:00',
      },
      {
        'id': 'forces',
        'name': 'កម្លាំងជុំវិញយើង',
        'thumbnail':
            'https://images.unsplash.com/photo-1636466497217-26a8cbeaf0aa?auto=format&fit=crop&w=900&q=80',
        'description': 'ស្វែងយល់កម្លាំងទាញ រុញ ទំនាញ កកិត និងតុល្យភាព។',
        'duration': '17:35',
      },
    ],
    'chemistry': [
      {
        'id': 'matter-states',
        'name': 'រូបធាតុ និងសភាព',
        'thumbnail':
            'https://images.unsplash.com/photo-1532094349884-543bc11b234d?auto=format&fit=crop&w=900&q=80',
        'description': 'ប្រៀបធៀបរឹង រាវ និងឧស្ម័នតាមឥរិយាបថភាគល្អិត។',
        'duration': '13:15',
      },
      {
        'id': 'atoms-elements',
        'name': 'អាតូម និងធាតុ',
        'thumbnail':
            'https://images.unsplash.com/photo-1532094349884-543bc11b234d?auto=format&fit=crop&w=900&q=80',
        'description': 'ស្វែងយល់អាតូម និងការរៀបចំធាតុគីមី។',
        'duration': '16:40',
      },
      {
        'id': 'simple-reactions',
        'name': 'ប្រតិកម្មគីមីសាមញ្ញ',
        'thumbnail':
            'https://images.unsplash.com/photo-1532094349884-543bc11b234d?auto=format&fit=crop&w=900&q=80',
        'description': 'ស្គាល់អង្គធាតុប្រតិករ ផលិតផល និងសញ្ញាបម្រែបម្រួល។',
        'duration': '19:05',
      },
    ],
    'biology': [
      {
        'id': 'living-things',
        'name': 'លក្ខណៈនៃជីវិត',
        'thumbnail':
            'https://images.unsplash.com/photo-1530026405186-ed1f139313f8?auto=format&fit=crop&w=900&q=80',
        'description': 'កំណត់លក្ខណៈរួមដែលបង្ហាញថាសារពាង្គកាយមានជីវិត។',
        'duration': '12:10',
      },
      {
        'id': 'cells',
        'name': 'សេចក្តីផ្តើមអំពីកោសិកា',
        'thumbnail':
            'https://images.unsplash.com/photo-1530026405186-ed1f139313f8?auto=format&fit=crop&w=900&q=80',
        'description':
            'ស្វែងយល់រចនាសម្ព័ន្ធកោសិកា និងប្រៀបធៀបកោសិការុក្ខជាតិនិងសត្វ។',
        'duration': '17:20',
      },
      {
        'id': 'ecosystems',
        'name': 'ប្រព័ន្ធអេកូឡូស៊ី',
        'thumbnail':
            'https://images.unsplash.com/photo-1530026405186-ed1f139313f8?auto=format&fit=crop&w=900&q=80',
        'description': 'សិក្សាការផ្ទេរថាមពលក្នុងសារពាង្គកាយនិងបរិស្ថាន។',
        'duration': '18:30',
      },
    ],
  };

  static const _englishQuizMockData = <String, Map<String, Object>>{
    'mathematics': {
      'question': 'Which operation is used to find a total?',
      'options': [
        'A) Addition',
        'B) Division',
        'C) Subtraction',
        'D) Rounding',
      ],
    },
    'physics': {
      'question': 'Which unit is commonly used to measure distance?',
      'options': ['A) Meter', 'B) Second', 'C) Kilogram', 'D) Celsius'],
    },
    'chemistry': {
      'question': 'Which of these is a state of matter?',
      'options': ['A) Solid', 'B) Energy', 'C) Light', 'D) Force'],
    },
    'biology': {
      'question': 'What is the basic unit of life?',
      'options': ['A) Cell', 'B) Atom', 'C) Rock', 'D) Molecule'],
    },
  };

  static const _khmerQuizMockData = <String, Map<String, Object>>{
    'mathematics': {
      'question': 'តើប្រមាណវិធីណាប្រើសម្រាប់រកចំនួនសរុប?',
      'options': ['ក) បូក', 'ខ) ចែក', 'គ) ដក', 'ឃ) បង្គត់'],
    },
    'physics': {
      'question': 'តើឯកតាណាប្រើសម្រាប់វាស់ចម្ងាយ?',
      'options': ['ក) ម៉ែត្រ', 'ខ) វិនាទី', 'គ) គីឡូក្រាម', 'ឃ) អង្សាសេ'],
    },
    'chemistry': {
      'question': 'តើមួយណាជាសភាពរបស់រូបធាតុ?',
      'options': ['ក) រឹង', 'ខ) ថាមពល', 'គ) ពន្លឺ', 'ឃ) កម្លាំង'],
    },
    'biology': {
      'question': 'តើអ្វីជាឯកតាមូលដ្ឋាននៃជីវិត?',
      'options': ['ក) កោសិកា', 'ខ) អាតូម', 'គ) ថ្ម', 'ឃ) ម៉ូលេគុល'],
    },
  };
}
