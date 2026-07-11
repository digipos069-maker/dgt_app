import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/models/grade_model.dart';
import 'grade_api_service.dart';

final gradeRepositoryProvider = Provider<GradeRepository>((ref) {
  return GradeRepository(GradeApiService());
});

class GradeRepository {
  const GradeRepository(this._apiService);

  final GradeApiService _apiService;

  Future<List<GradeModel>> fetchGrades() async {
    final grades = await _apiService.fetchGrades();
    return grades
        .map(GradeModel.fromJson)
        .where((grade) => grade.id > 0)
        .toList(growable: false);
  }
}
