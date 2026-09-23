import 'package:icalendar_parser/icalendar_parser.dart';
import 'package:kalender/kalender.dart';

class CalendarEvent extends KalenderEvent {
  final String title;
  final String? location;
  final String? subject;

  CalendarEvent({
    super.id,
    required super.start,
    required super.end,
    required this.title,
    this.location,
    this.subject,
  });

  @override
  CalendarEvent copyWithData({required DateTime start, required DateTime end}) {
    return CalendarEvent(
      start: start,
      end: end,
      title: title,
      location: location,
      subject: subject,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return super == other &&
        other is CalendarEvent &&
        other.title == title &&
        other.location == location &&
        other.subject == subject;
  }

  factory CalendarEvent.fromJson(Map<String, dynamic> json) {
    return CalendarEvent(
      title: json['summary'] as String,
      start: (json['dtstart'] as IcsDateTime).toDateTime()!,
      end: (json['dtend'] as IcsDateTime).toDateTime()!,
      location: json['location'] as String?,
      subject: (json['categories'] as List?)?.cast<String>().firstOrNull,
    );
  }

  @override
  int get hashCode => Object.hash(super.hashCode, title, location, subject);
}
