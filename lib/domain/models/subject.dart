class Subject {
  final String name;
  final String semester;

  const Subject({required this.name, required this.semester});

  factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(
        name: json['name'] as String, semester: json['semester'] as String);
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'semester': semester,
      };
}
