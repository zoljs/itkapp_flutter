import 'package:flutter_test/flutter_test.dart';
import 'package:itk_app/domain/models/midterm_date.dart';

Map<String, dynamic> validSubjectJson() => {
      'id': 1,
      'code': 'ABC123',
      'name': 'Analízis I.',
    };

Map<String, dynamic> validJson() => {
      'id': 10,
      'createdBy': 5,
      'startsAt': '2026-11-03T10:00:00.000Z',
      'location': 'PPKE ITK 101',
      'subject': validSubjectJson(),
    };

void main() {
  group('MidtermDate.fromJson', () {
    test('parses a valid json', () {
      final midterm = MidtermDate.fromJson(validJson());

      expect(midterm.id, 10);
      expect(midterm.createdBy, 5);
      expect(midterm.startsAt.toUtc(), DateTime.utc(2026, 11, 3, 10));
      expect(midterm.location, 'PPKE ITK 101');
      expect(midterm.subject.code, 'ABC123');
    });

    test('accepts null location and createdBy', () {
      final json = validJson()
        ..['location'] = null
        ..['createdBy'] = null;

      final midterm = MidtermDate.fromJson(json);

      expect(midterm.location, isNull);
      expect(midterm.createdBy, isNull);
    });

    final invalidCases = <String, Map<String, dynamic>>{
      'id is missing': validJson()..remove('id'),
      'startsAt is missing': validJson()..remove('startsAt'),
      'startsAt is not a date': validJson()..['startsAt'] = 'not a date',
      'subject is missing': validJson()..remove('subject'),
      'subject is invalid': validJson()
        ..['subject'] = (validSubjectJson()..['name'] = ''),
    };

    for (final entry in invalidCases.entries) {
      test('throws FormatException when ${entry.key}', () {
        expect(() => MidtermDate.fromJson(entry.value), throwsFormatException);
      });
    }
  });
}
