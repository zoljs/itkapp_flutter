import 'package:flutter_test/flutter_test.dart';
import 'package:itk_app/domain/models/wiki_file.dart';

Map<String, dynamic> file(String name, {String type = 'file'}) =>
    {'name': name, 'type': type};

void main() {
  group('WikiFile.fromJson', () {
    test('mappa és fájl', () {
      expect(WikiFile.fromJson(file('Analizis', type: 'dir')).isDir, isTrue);
      expect(WikiFile.fromJson(file('zh1.pdf')).isDir, isFalse);
    });

    test('üres név FormatException', () {
      expect(() => WikiFile.fromJson(file('  ')), throwsFormatException);
    });

    test('ismeretlen típus FormatException', () {
      expect(() => WikiFile.fromJson(file('x', type: 'link')),
          throwsFormatException);
    });

    test('útvonal-karakter a névben FormatException', () {
      expect(() => WikiFile.fromJson(file('../x')), throwsFormatException);
      expect(() => WikiFile.fromJson(file('a/b')), throwsFormatException);
      expect(() => WikiFile.fromJson(file('a\\b')), throwsFormatException);
    });

    test('. és .. név FormatException', () {
      expect(() => WikiFile.fromJson(file('.')), throwsFormatException);
      expect(() => WikiFile.fromJson(file('..')), throwsFormatException);
    });

    test('pontot tartalmazó név elfogadott', () {
      expect(WikiFile.fromJson(file('a.pdf')).name, 'a.pdf');
      expect(WikiFile.fromJson(file('..pdf')).name, '..pdf');
    });

    test('vezérlőkarakter a névben FormatException', () {
      expect(() => WikiFile.fromJson(file('a\nb')), throwsFormatException);
      expect(() => WikiFile.fromJson(file('a\x00b')), throwsFormatException);
      expect(() => WikiFile.fromJson(file('a\x7Fb')), throwsFormatException);
    });

    test('255 karakteres név még elfogadott', () {
      expect(WikiFile.fromJson(file('a' * 255)).name, hasLength(255));
    });

    test('256 karakteres név FormatException', () {
      expect(() => WikiFile.fromJson(file('a' * 256)), throwsFormatException);
    });
  });

  group('WikiFile.parseList', () {
    test('a nem lista FormatException', () {
      expect(() => WikiFile.parseList('nem lista'), throwsFormatException);
    });

    test('pontosan a maximum még elfogadott', () {
      final data = List.generate(WikiFile.maxFiles, (i) => file('f$i'));
      expect(WikiFile.parseList(data), hasLength(WikiFile.maxFiles));
    });

    test('a maximumnál több elem FormatException', () {
      final data = List.generate(WikiFile.maxFiles + 1, (i) => file('f$i'));
      expect(() => WikiFile.parseList(data), throwsFormatException);
    });
  });
}
