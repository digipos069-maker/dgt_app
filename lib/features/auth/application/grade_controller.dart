import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/grade_repository.dart';
import '../domain/models/grade_model.dart';

final gradesProvider = FutureProvider<List<GradeModel>>((ref) {
  return ref.watch(gradeRepositoryProvider).fetchGrades();
});
