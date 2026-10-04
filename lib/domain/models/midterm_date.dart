import 'package:itk_app/domain/models/subject.dart';

class MidtermDate {
  final int id;
  final int? createdBy;
  final DateTime startsAt;
  final String? location;
  final Subject subject;

  const MidtermDate({
    required this.id,
    this.createdBy,
    required this.startsAt,
    this.location,
    required this.subject,
  });

  factory MidtermDate.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    if (id is! int) {
      throw const FormatException('Egy ZH-nak hiányzik az id-je.');
    }

    final createdBy = json['createdBy'];
    if (createdBy != null && createdBy is! int) {
      throw const FormatException('Hibás createdBy.');
    }

    final location = json['location'];
    if (location != null && location is! String) {
      throw const FormatException('Egy ZH-nak hibás a helyszíne.');
    }

    final startsAt = json['startsAt'];
    if (startsAt is! String) {
      throw const FormatException('Egy ZH-nak hiányzik a kezdése.');
    }

    final parsedStartsAt = DateTime.tryParse(startsAt);
    if (parsedStartsAt is! DateTime) {
      throw const FormatException('Egy ZH-nak hibás a kezdése.');
    }

    final subject = json['subject'];
    if (subject is! Map<String, dynamic>) {
      throw const FormatException('Egy ZH-nak hiányzik a tárgya.');
    }

    return MidtermDate(
      id: id,
      createdBy: createdBy,
      startsAt: parsedStartsAt,
      location: location,
      subject: Subject.fromJson(subject),
    );
  }
}
