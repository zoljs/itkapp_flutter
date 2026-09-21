import 'package:icalendar_parser/icalendar_parser.dart';

class CalendarEvent {
  final String title;
  final String? location;
  final DateTime start;
  final DateTime end;
  final String? subject;

  const CalendarEvent({
    required this.title,
    required this.start,
    required this.end,
    this.location,
    this.subject,
  });

  factory CalendarEvent.fromJson(Map<String, dynamic> json) {
    return CalendarEvent(
      title: json['summary'] as String,
      start: (json['dtstart'] as IcsDateTime).toDateTime()!,
      end: (json['dtend'] as IcsDateTime).toDateTime()!,
      location: json['location'] as String?,
      subject: (json['categories'] as List).first,
    );
  }
}
