import 'package:flutter_test/flutter_test.dart';
import 'package:itk_app/domain/models/user_site.dart';

Map<String, dynamic> validJson() => {
      'login': 'perpa4',
      'name': 'Teszt Elek',
      'url': 'https://users.itk.ppke.hu/~perpa4',
      'tags': ['Analízis I.'],
    };

void main() {
  group('UserSite.fromJson', () {
    test('reads claimed when true', () {
      final site = UserSite.fromJson(validJson()..['claimed'] = true);
      expect(site.claimed, isTrue);
    });

    test('reads claimed when false', () {
      final site = UserSite.fromJson(validJson()..['claimed'] = false);
      expect(site.claimed, isFalse);
    });

    test('defaults claimed to false when missing', () {
      final site = UserSite.fromJson(validJson());
      expect(site.claimed, isFalse);
    });
  });
}
