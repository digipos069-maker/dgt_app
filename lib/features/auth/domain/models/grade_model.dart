class GradeModel {
  const GradeModel({required this.id, required this.name});

  final int id;
  final String name;

  @override
  bool operator ==(Object other) {
    return identical(this, other) || other is GradeModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  factory GradeModel.fromJson(Object? value) {
    if (value is int) {
      return GradeModel(id: value, name: 'Grade $value');
    }

    if (value is String) {
      final id = int.tryParse(value.replaceAll(RegExp(r'[^0-9]'), ''));
      return GradeModel(id: id ?? 0, name: value);
    }

    if (value is Map<String, dynamic>) {
      final id =
          _readInt(value['id']) ??
          _readInt(value['gradeId']) ??
          _readInt(value['value']) ??
          0;
      final name =
          _readString(value['name']) ??
          _readString(value['title']) ??
          _readString(value['label']) ??
          _readString(value['gradeName']) ??
          'Grade $id';

      return GradeModel(id: id, name: name);
    }

    return const GradeModel(id: 0, name: 'Unknown grade');
  }

  static int? _readInt(Object? value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '');
  }

  static String? _readString(Object? value) {
    if (value == null) return null;
    final text = value.toString().trim();
    return text.isEmpty ? null : text;
  }
}
