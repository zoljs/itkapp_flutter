import 'package:icalendar_parser/icalendar_parser.dart';

class CalendarEvent {
  final String title;
  final String? location;
  final String? subject;
  final DateTime start;
  final DateTime end;

  const CalendarEvent({
    required this.title,
    required this.start,
    required this.end,
    this.location,
    this.subject,
  });

  factory CalendarEvent.fromJson(Map<String, dynamic> json) {
    final title = json['summary'] ?? 'Névtelen esemény';
    if (title is! String) {
      throw const FormatException('Egy eseménynek hibás a címe.');
    }

    final start = _readIcsDate(json['dtstart']);
    if (start == null) {
      throw const FormatException('Egy eseménynek hiányzik a kezdése.');
    }

    // DTEND is optional in ICS (instant or all-day events), fall back to the start.
    final end = _readIcsDate(json['dtend']) ?? start;

    final location = json['location'];
    if (location is! String?) {
      throw const FormatException('Egy eseménynek hibás a helyszíne.');
    }

    final subject = switch (json['categories']) {
      [final String first, ...] => first,
      _ => null,
    };

    return CalendarEvent(
      title: title,
      start: start,
      end: end,
      location: location,
      subject: subject,
    );
  }

  /// Parses an ICS string into a list of CalendarEvent objects.
  /// We filter with where to only include VEVENT items, and use tryParseIcsEvent to skip events that cannot be parsed.
  /// Since that one returns null on failure, we can use nonNulls to filter them out.
  static List<CalendarEvent> parseIcs(String ics) {
    return ICalendar.fromString(ics).data.where((item) => item['type'] == 'VEVENT').map(tryParseIcsEvent).nonNulls.toList();
  }

  static CalendarEvent? tryParseIcsEvent(Map<String, dynamic> json) {
    try {
      return CalendarEvent.fromJson(json);
    } on FormatException {
      return null;
    }
  }

  static DateTime? _readIcsDate(Object? value) => value is IcsDateTime ? value.toDateTime() : null;
}
