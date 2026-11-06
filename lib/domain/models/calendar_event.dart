import 'package:flutter/foundation.dart';
import 'package:icalendar_parser/icalendar_parser.dart';

class CalendarEvent {
  final String title;
  final String? location;
  final String? subject;
  final DateTime start;
  final DateTime end;

  static bool _isMidnight(DateTime t) =>
      t.hour == 0 && t.minute == 0 && t.second == 0;

  bool get isAllDay {
    final s = start.toLocal();
    final e = end.toLocal();
    if (!_isMidnight(s)) return false;
    return s == e || (_isMidnight(e) && e.isAfter(s));
  }

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
        } ??
        subjectFromTitle(title);

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
    return ICalendar.fromString(ics)
        .data
        .where((item) => item['type'] == 'VEVENT')
        .map(tryParseIcsEvent)
        .nonNulls
        .toList();
  }

  static CalendarEvent? tryParseIcsEvent(Map<String, dynamic> json) {
    try {
      return CalendarEvent.fromJson(json);
    } on FormatException {
      return null;
    }
  }

  static List<CalendarEvent> parseIcsResponse(Object? data) {
    if (data is! String || data.trim().isEmpty) return const [];

    // Parse data from response
    try {
      return CalendarEvent.parseIcs(data);
    } on Exception catch (e) {
      debugPrint('[CalendarEvent] ICS parse error: $e');
      throw const FormatException('Nem sikerült feldolgozni a naptárat.');
    }
  }

  static DateTime? _readIcsDate(Object? value) =>
      value is IcsDateTime ? value.toDateTime() : null;

  static String? subjectFromTitle(String title) {
    final i = title.lastIndexOf(' (');
    if (i <= 0) return null;
    return title.substring(0, i).trim();
  }
}
