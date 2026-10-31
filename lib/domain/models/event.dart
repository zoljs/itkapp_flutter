import 'package:itk_app/domain/models/subject.dart';

enum EventType {
  midterm('MIDTERM', 'ZH'),
  retake('RETAKE', 'Pót ZH'),
  consultation('CONSULTATION', 'Konzultáció');

  final String wire;
  final String label;

  const EventType(this.wire, this.label);

  static EventType fromWire(Object? value) {
    for (final type in values) {
      if (type.wire == value) return type;
    }
    throw FormatException('Ismeretlen esemény típus: $value');
  }
}

class Event {
  final int id;
  final int? createdBy;
  final DateTime startsAt;
  final String? location;
  final Subject subject;
  final EventType type;

  const Event({
    required this.id,
    this.createdBy,
    required this.startsAt,
    this.location,
    required this.subject,
    this.type = EventType.midterm,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    if (id is! int) {
      throw const FormatException('Egy eseménynek hiányzik az id-je.');
    }

    final createdBy = json['createdBy'];
    if (createdBy != null && createdBy is! int) {
      throw const FormatException('Hibás createdBy.');
    }

    final location = json['location'];
    if (location != null && location is! String) {
      throw const FormatException('Egy eseménynek hibás a helyszíne.');
    }

    final startsAt = json['startsAt'];
    if (startsAt is! String) {
      throw const FormatException('Egy eseménynek hiányzik a kezdése.');
    }

    final parsedStartsAt = DateTime.tryParse(startsAt);
    if (parsedStartsAt is! DateTime) {
      throw const FormatException('Egy eseménynek hibás a kezdése.');
    }

    return Event(
      id: id,
      createdBy: createdBy,
      startsAt: parsedStartsAt,
      location: location,
      subject: Subject.parse(json['subject']),
      type: EventType.fromWire(json['type'] ?? 'MIDTERM'),
    );
  }

  static Event parse(Object? data) {
    if (data is! Map<String, dynamic>) {
      throw const FormatException('Egy esemény nem objektum formátumú.');
    }
    return Event.fromJson(data);
  }

  static List<Event> parseList(Object? data) {
    if (data is! List) {
      throw const FormatException('Az esemény lista nem lista formátumú.');
    }
    return List.unmodifiable(data.map(parse));
  }
}
