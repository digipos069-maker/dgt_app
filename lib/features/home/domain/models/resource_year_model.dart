import 'exam_resource_model.dart';

class ResourceYearModel {
  const ResourceYearModel({required this.year, required this.resourceCount});

  final int year;
  final int resourceCount;
}

class ResourceYearBundle {
  const ResourceYearBundle({required this.exam, required this.years});

  final ExamResourceModel exam;
  final List<ResourceYearModel> years;
}
