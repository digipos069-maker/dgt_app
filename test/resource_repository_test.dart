import 'package:dgt_app/features/home/data/resource_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const repository = ResourceRepository();

  test('returns localized exam resources with access states', () async {
    final english = await repository.fetchResources(languageCode: 'en');
    final khmer = await repository.fetchResources(languageCode: 'km');

    expect(english, hasLength(5));
    expect(khmer, hasLength(5));
    expect(khmer.first.examName, 'ប្រឡងសិស្សពូកែ');
    expect(english.first.icon, 'trophy');
    expect(english.any((resource) => resource.isLocked), isTrue);
    expect(english.any((resource) => !resource.isLocked), isTrue);
  });
}
