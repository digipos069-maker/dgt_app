import 'package:dgt_app/features/auth/domain/models/grade_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses the grade API response shape', () {
    final grade = GradeModel.fromJson({'id': 11, 'number': 11});

    expect(grade.id, 11);
    expect(grade.number, 11);
    expect(grade.name, 'Grade 11');
  });
}
