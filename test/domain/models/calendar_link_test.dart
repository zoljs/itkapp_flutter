import 'package:flutter_test/flutter_test.dart';
import 'package:itk_app/domain/models/calendar_link.dart';

Map<String, dynamic> validJson() => {
      'id': 3,
      'name': 'Neptun',
      'url': 'https://neptun.example/cal.ics',
      'syncInterval': '6h',
      'lastSyncedAt': '2026-10-28T14:07:40.713Z',
      'lastError': null,
    };

void main() {
  group('SyncInterval.fromWire', () {
    test('minden szerver értéket ismer', () {
      expect(SyncInterval.fromWire('1h'), SyncInterval.hourly);
      expect(SyncInterval.fromWire('6h'), SyncInterval.sixHours);
      expect(SyncInterval.fromWire('1d'), SyncInterval.daily);
    });

    test('ismeretlen érték FormatException', () {
      expect(() => SyncInterval.fromWire('15m'), throwsFormatException);
      expect(() => SyncInterval.fromWire(null), throwsFormatException);
      // The enum itself is not a wire value: this was a real bug once.
      expect(() => SyncInterval.fromWire(SyncInterval.daily), throwsFormatException);
    });
  });

  group('CalendarLink.fromJson', () {
    test('beolvassa a teljes linket', () {
      final link = CalendarLink.fromJson(validJson());

      expect(link.id, 3);
      expect(link.name, 'Neptun');
      expect(link.url, 'https://neptun.example/cal.ics');
      expect(link.syncInterval, SyncInterval.sixHours);
      expect(link.lastSyncedAt, DateTime.utc(2026, 10, 28, 14, 7, 40, 713));
      expect(link.lastError, isNull);
    });

    test('a még nem szinkronizált link null időpontot kap', () {
      final link = CalendarLink.fromJson({...validJson(), 'lastSyncedAt': null});
      expect(link.lastSyncedAt, isNull);
    });

    test('a hibaüzenet átjön', () {
      final link = CalendarLink.fromJson({...validJson(), 'lastError': 'Nem sikerült letölteni a naptárat.'});
      expect(link.lastError, 'Nem sikerült letölteni a naptárat.');
    });

    final invalid = <String, Map<String, dynamic>>{
      'hiányzik az id': {...validJson()}..remove('id'),
      'az id szöveg': {...validJson(), 'id': '3'},
      'hiányzik a név': {...validJson()}..remove('name'),
      'hiányzik az url': {...validJson()}..remove('url'),
      'rossz a dátum': {...validJson(), 'lastSyncedAt': 'tegnap'},
      'a dátum szám': {...validJson(), 'lastSyncedAt': 123},
      'a hiba szám': {...validJson(), 'lastError': 42},
      'ismeretlen időköz': {...validJson(), 'syncInterval': '2d'},
    };
    for (final entry in invalid.entries) {
      test('FormatException, ha ${entry.key}', () {
        expect(() => CalendarLink.fromJson(entry.value), throwsFormatException);
      });
    }
  });

  group('CalendarLink.parse / parseList', () {
    test('a nem objektum FormatException', () {
      expect(() => CalendarLink.parse('szöveg'), throwsFormatException);
    });

    test('a nem lista FormatException', () {
      expect(() => CalendarLink.parseList({'id': 1}), throwsFormatException);
    });

    test('egy rossz elem az egész listát elutasítja', () {
      expect(
        () => CalendarLink.parseList([validJson(), {'id': 'x'}]),
        throwsFormatException,
      );
    });

    test('jó lista', () {
      expect(CalendarLink.parseList([validJson(), {...validJson(), 'id': 4}]), hasLength(2));
    });
  });
}
