import 'package:flutter_test/flutter_test.dart';
import 'package:itk_app/domain/models/calendar_event.dart';

String ics(List<String> events) => [
      'BEGIN:VCALENDAR',
      'VERSION:2.0',
      'PRODID:-//ITKApp//Test//EN',
      ...events,
      'END:VCALENDAR',
    ].join('\r\n');

String vevent(List<String> lines) =>
    ['BEGIN:VEVENT', ...lines, 'END:VEVENT'].join('\r\n');

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

  group('CalendarEvent.subjectFromTitle (Neptun SUMMARY)', () {
    final cases = <String, String?>{
      'Computer Controlled Systems ( - 01) - Dr. Pongrácz Barna - Tanóra':
          'Computer Controlled Systems',
      'Információ- és kódelmélet (Írásbeli és szóbeli) - Dr. Oláh András - Vizsga':
          'Információ- és kódelmélet',
      'Fizika (mérnököknek) ( - 00) - Dr. X - Tanóra': 'Fizika (mérnököknek)',
      'Saját esemény': null,
      ' ( - 01) - Tanóra': null,
    };
    for (final entry in cases.entries) {
      test('${entry.key} -> ${entry.value}', () {
        expect(CalendarEvent.subjectFromTitle(entry.key), entry.value);
      });
    }

    test('CATEGORIES nélkül a tárgy a címből jön', () {
      final event = CalendarEvent.parseIcs(ics([
        vevent([
          'UID:1',
          'SUMMARY:Computer Controlled Systems ( - 01) - Dr. Pongrácz Barna - Tanóra',
          'DTSTART:20261103T080000Z',
        ]),
      ])).single;

      expect(event.subject, 'Computer Controlled Systems');
    });

    test('a CATEGORIES elsőbbséget élvez a címmel szemben', () {
      final event = CalendarEvent.parseIcs(ics([
        vevent([
          'UID:1',
          'SUMMARY:Valami más ( - 01) - Dr. X - Tanóra',
          'CATEGORIES:Analízis I.',
          'DTSTART:20261103T080000Z',
        ]),
      ])).single;

      expect(event.subject, 'Analízis I.');
    });
  });

  group('isAllDay', () {
    CalendarEvent at(DateTime start, DateTime end) =>
        CalendarEvent(title: 'x', start: start, end: end);

    test('Neptun: ugyanazon nap 0:00-0:00 egész napos', () {
      final midnight = DateTime(2026, 11, 5);
      expect(at(midnight, midnight).isAllDay, isTrue);
    });

    test('éjféltől másnap éjfélig egész napos', () {
      expect(at(DateTime(2026, 11, 5), DateTime(2026, 11, 6)).isAllDay, isTrue);
    });

    test('több napos, éjféltől éjfélig egész napos', () {
      expect(at(DateTime(2026, 11, 5), DateTime(2026, 11, 8)).isAllDay, isTrue);
    });

    test('Moodle határidő (pillanat, nem éjfélkor) nem egész napos', () {
      final due = DateTime(2026, 11, 5, 23, 59);
      expect(at(due, due).isAllDay, isFalse);
    });

    test('0:30-as pillanat nem egész napos', () {
      final t = DateTime(2026, 11, 5, 0, 30);
      expect(at(t, t).isAllDay, isFalse);
    });

    test('éjféltől délig tartó esemény nem egész napos', () {
      expect(at(DateTime(2026, 11, 5), DateTime(2026, 11, 5, 12)).isAllDay,
          isFalse);
    });

    test('normál óra nem egész napos', () {
      expect(at(DateTime(2026, 11, 5, 10), DateTime(2026, 11, 5, 12)).isAllDay,
          isFalse);
    });

    test('VALUE=DATE esemény az ICS-ből egész napos', () {
      final events = CalendarEvent.parseIcs(ics([
        'BEGIN:VEVENT',
        'UID:1',
        'SUMMARY:Szünnap',
        'DTSTART;VALUE=DATE:20261105',
        'DTEND;VALUE=DATE:20261106',
        'END:VEVENT',
      ]));
      expect(events.single.isAllDay, isTrue);
    });
  });
}
