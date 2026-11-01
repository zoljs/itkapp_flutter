import 'package:flutter_test/flutter_test.dart';
import 'package:itk_app/domain/models/calendar_event.dart';

String ics(List<String> events) => [
      'BEGIN:VCALENDAR',
      'VERSION:2.0',
      'PRODID:-//ITKApp//Test//EN',
      ...events,
      'END:VCALENDAR',
    ].join('\r\n');

String vevent(List<String> lines) => ['BEGIN:VEVENT', ...lines, 'END:VEVENT'].join('\r\n');

void main() {
  group('CalendarEvent.parseIcs', () {
    test('beolvassa a teljes eseményt', () {
      final events = CalendarEvent.parseIcs(ics([
        vevent([
          'UID:1',
          'SUMMARY:Analízis előadás',
          'LOCATION:318',
          'CATEGORIES:Analízis I.',
          'DTSTART:20261103T080000Z',
          'DTEND:20261103T094500Z',
        ]),
      ]));

      expect(events, hasLength(1));
      final event = events.single;
      expect(event.title, 'Analízis előadás');
      expect(event.location, '318');
      expect(event.subject, 'Analízis I.');
      expect(event.start.toUtc(), DateTime.utc(2026, 11, 3, 8));
      expect(event.end.toUtc(), DateTime.utc(2026, 11, 3, 9, 45));
    });

    test('DTEND nélkül a vége a kezdés', () {
      final event = CalendarEvent.parseIcs(ics([
        vevent(['UID:1', 'SUMMARY:Határidő', 'DTSTART:20261103T080000Z']),
      ])).single;

      expect(event.end, event.start);
    });

    test('SUMMARY nélkül „Névtelen esemény” lesz a cím', () {
      final event = CalendarEvent.parseIcs(ics([
        vevent(['UID:1', 'DTSTART:20261103T080000Z']),
      ])).single;

      expect(event.title, 'Névtelen esemény');
    });

    test('a hibás esemény kimarad, a többi megmarad', () {
      final events = CalendarEvent.parseIcs(ics([
        vevent(['UID:1', 'SUMMARY:Jó 1', 'DTSTART:20261103T080000Z']),
        vevent(['UID:2', 'SUMMARY:Kezdés nélkül']),
        vevent(['UID:3', 'SUMMARY:Jó 2', 'DTSTART:20261104T080000Z']),
      ]));

      expect(events.map((e) => e.title), ['Jó 1', 'Jó 2']);
    });

    test('üres naptár üres lista', () {
      expect(CalendarEvent.parseIcs(ics([])), isEmpty);
    });
  });
}
