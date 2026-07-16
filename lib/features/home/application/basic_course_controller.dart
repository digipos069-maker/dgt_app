import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/basic_course_repository.dart';
import '../domain/models/basic_course_model.dart';

final basicCoursesProvider = FutureProvider.autoDispose
    .family<List<BasicCourseModel>, String>((ref, languageCode) {
      return ref
          .watch(basicCourseRepositoryProvider)
          .fetchBasicCourses(languageCode: languageCode);
    });
