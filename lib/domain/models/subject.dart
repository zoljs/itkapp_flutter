class Subject {
  final int id;
  final String code;
  final String name;

  const Subject({required this.name, required this.code, required this.id});

  factory Subject.fromJson(Map<String, dynamic> json) {
    final name = json['name'];
    if (name is! String || name.trim().isEmpty) {
      throw const FormatException('Egy tárgynak hiányzik a neve.');
    }

    final id = json['id'];
    if (id is! int) {
      throw const FormatException('Egy tárgynak hiányzik az id-je.');
    }

    final code = json['code'];
    if (code is! String || code.trim().isEmpty) {
      throw const FormatException('Egy tárgynak hiányzik a kódja.');
    }

    return Subject(name: name, code: code, id: id);
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'code': code,
        'id': id,
      };

  static Subject parse(Object? data) {
    if (data is! Map<String, dynamic>) {
      throw const FormatException('A tárgy nem objektum formátumú.');
    }
    return Subject.fromJson(data);
  }

  static List<Subject> parseList(Object? data) {
    if (data is! List) {
      throw const FormatException('A tárgylista nem lista formátumú.');
    }

    return List.unmodifiable(data.map(parse));
  }
}
