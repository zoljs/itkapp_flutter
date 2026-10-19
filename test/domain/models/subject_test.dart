import 'package:flutter_test/flutter_test.dart';
import 'package:itk_app/domain/models/subject.dart';

Map<String, dynamic> validJson() => {
      'id': 1,
      'code': 'ABC123',
      'name': 'Analízis I.',
    };

void main() {
  group('Subject.fromJson', () {
    test('parses a valid json', () {
      final subject = Subject.fromJson(validJson());

      expect(subject.id, 1);
      expect(subject.code, 'ABC123');
      expect(subject.name, 'Analízis I.');
    });

    test('throws FormatException when missing id', () {
      final json = validJson()..remove('id');

      expect(() => Subject.fromJson(json), throwsFormatException);
    });

    test('throws FormatException when missing code', () {
      final json = validJson()..remove('code');

      expect(() => Subject.fromJson(json), throwsFormatException);
    });

    test('throws FormatException when missing name', () {
      final json = validJson()..remove('name');

      expect(() => Subject.fromJson(json), throwsFormatException);
    });

    test('throws FormatException when id is not an int', () {
      final json = validJson()..['id'] = 'not an int';

      expect(() => Subject.fromJson(json), throwsFormatException);
    });

    test('throws FormatException when code is not a string', () {
      final json = validJson()..['code'] = 123;

      expect(() => Subject.fromJson(json), throwsFormatException);
    });

    test('throws FormatException when name is not a string', () {
      final json = validJson()..['name'] = 123;

      expect(() => Subject.fromJson(json), throwsFormatException);
    });

    test('throws FormatException when code is empty', () {
      final json = validJson()..['code'] = '';

      expect(() => Subject.fromJson(json), throwsFormatException);
    });

    test('throws FormatException when name is empty', () {
      final json = validJson()..['name'] = '';

      expect(() => Subject.fromJson(json), throwsFormatException);
    });

    test('throws FormatException when name is blank', () {
      final json = validJson()..['name'] = '    ';

      expect(() => Subject.fromJson(json), throwsFormatException);
    });

    test('throws FormatException when code is blank', () {
      final json = validJson()..['code'] = '    ';

      expect(() => Subject.fromJson(json), throwsFormatException);
    });
  });
}
