import 'package:flutter_test/flutter_test.dart';
import 'package:itk_app/domain/models/event.dart';

Map<String, dynamic> validJson() => {
      'id': 10,
      'startsAt': '2026-11-03T10:00:00.000Z',
      'subject': {'id': 1, 'code': 'ITK101', 'name': 'Analízis I.'},
    };

void main() {
  group('EventType.fromWire', () {
    test('minden szerver értéket ismer', () {
      expect(EventType.fromWire('MIDTERM'), EventType.midterm);
      expect(EventType.fromWire('RETAKE'), EventType.retake);
      expect(EventType.fromWire('CONSULTATION'), EventType.consultation);
    });

    test('ismeretlen érték FormatException', () {
      expect(() => EventType.fromWire('EXAM'), throwsFormatException);
      expect(() => EventType.fromWire(null), throwsFormatException);
    });
  });

  group('Event.fromJson type', () {
    test('type nélkül (régi szerver) ZH', () {
      expect(Event.fromJson(validJson()).type, EventType.midterm);
    });

    test('a megadott típus átjön', () {
      expect(Event.fromJson({...validJson(), 'type': 'RETAKE'}).type, EventType.retake);
      expect(Event.fromJson({...validJson(), 'type': 'CONSULTATION'}).type, EventType.consultation);
    });

    test('ismeretlen típus FormatException', () {
      expect(() => Event.fromJson({...validJson(), 'type': 'PARTY'}), throwsFormatException);
    });
  });

  group('Event.parse / parseList', () {
    test('a nem objektum FormatException', () {
      expect(() => Event.parse(42), throwsFormatException);
    });

    test('a nem lista FormatException', () {
      expect(() => Event.parseList(validJson()), throwsFormatException);
    });

    test('jó lista', () {
      expect(Event.parseList([validJson(), {...validJson(), 'id': 11}]), hasLength(2));
    });
  });
}
