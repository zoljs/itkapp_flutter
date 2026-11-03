import 'package:flutter_test/flutter_test.dart';
import 'package:itk_app/domain/models/site_color.dart';
import 'package:itk_app/domain/models/user_site.dart';

Map<String, dynamic> validJson() => {
      'login': 'perpa4',
      'name': 'Perényi Pál',
      'url': 'https://users.itk.ppke.hu/~perpa4/',
      'tags': ['Analízis'],
      'color': 'green',
    };

void main() {
  group('color', () {
    test('beolvassa az ismert színt', () {
      expect(UserSite.fromJson(validJson()).color, SiteColor.green);
    });

    test('hiányzó szín -> alapértelmezett', () {
      final json = validJson()..remove('color');
      expect(UserSite.fromJson(json).color, SiteColor.fallback);
    });

    test('null szín -> alapértelmezett', () {
      expect(UserSite.fromJson({...validJson(), 'color': null}).color, SiteColor.fallback);
    });

    test('ismeretlen szín -> alapértelmezett (újabb backend, régi app)', () {
      expect(UserSite.fromJson({...validJson(), 'color': 'pink'}).color, SiteColor.fallback);
    });

    final invalid = <String, Object>{
      'szám': 42,
      'lista': ['green'],
      'bool': true,
    };
    for (final entry in invalid.entries) {
      test('FormatException, ha a szín ${entry.key}', () {
        expect(() => UserSite.fromJson({...validJson(), 'color': entry.value}), throwsFormatException);
      });
    }
  });

  test('a parseList a hibás színt is FormatException-ként jelzi', () {
    expect(() => UserSite.parseList([validJson(), {...validJson(), 'color': 42}]), throwsFormatException);
  });
}
