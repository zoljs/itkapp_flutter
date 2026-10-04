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
}
