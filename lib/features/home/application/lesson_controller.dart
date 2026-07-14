import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/lesson_repository.dart';
import '../domain/models/lesson_model.dart';

final lessonBundleProvider = FutureProvider.autoDispose
    .family<CourseLessonBundle, String>((ref, courseId) {
      return ref.watch(lessonRepositoryProvider).fetchLessons(courseId);
    });
