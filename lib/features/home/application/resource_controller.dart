import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/resource_repository.dart';
import '../domain/models/exam_resource_model.dart';

final examResourcesProvider = FutureProvider.autoDispose
    .family<List<ExamResourceModel>, String>((ref, languageCode) {
      return ref
          .watch(resourceRepositoryProvider)
          .fetchResources(languageCode: languageCode);
    });
