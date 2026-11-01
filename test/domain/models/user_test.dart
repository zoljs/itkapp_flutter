import 'package:flutter_test/flutter_test.dart';
import 'package:itk_app/domain/models/user.dart';

Map<String, dynamic> validJson() => {
      'id': 1,
      'login': 'perpa4',
      'email': 'perpa4@itk.ppke.hu',
      'name': 'Teszt Elek',
      'givenName': 'Elek',
      'familyName': 'Teszt',
      'canModerateMidterms': true,
      'isAdmin': true,
    };

void main() {
  group('LdapUser.fromJson', () {
    test('beolvassa a teljes usert', () {
      final user = LdapUser.fromJson(validJson());

      expect(user.id, 1);
      expect(user.login, 'perpa4');
      expect(user.email, 'perpa4@itk.ppke.hu');
      expect(user.canModerateMidterms, isTrue);
      expect(user.isAdmin, isTrue);
    });

    test('a hiányzó jogosultságok false-ok', () {
      final json = validJson()
        ..remove('canModerateMidterms')
        ..remove('isAdmin');
      final user = LdapUser.fromJson(json);

      expect(user.canModerateMidterms, isFalse);
      expect(user.isAdmin, isFalse);
    });

    final invalid = <String, Map<String, dynamic>>{
      'hiányzik az id': {...validJson()}..remove('id'),
      'hiányzik a login': {...validJson()}..remove('login'),
      'hiányzik a keresztnév': {...validJson()}..remove('givenName'),
      'hiányzik a vezetéknév': {...validJson()}..remove('familyName'),
      'az email szám': {...validJson(), 'email': 5},
      'az isAdmin szöveg': {...validJson(), 'isAdmin': 'true'},
    };
    for (final entry in invalid.entries) {
      test('FormatException, ha ${entry.key}', () {
        expect(() => LdapUser.fromJson(entry.value), throwsFormatException);
      });
    }
  });

  test('toJson → fromJson oda-vissza ugyanaz (a cache ezt használja)', () {
    final original = LdapUser.fromJson(validJson());
    final restored = LdapUser.fromJson(original.toJson());

    // isAdmin was missing from toJson once, admins lost the admin menu after a restart.
    expect(restored.isAdmin, original.isAdmin);
    expect(restored.canModerateMidterms, original.canModerateMidterms);
    expect(restored.login, original.login);
    expect(restored.email, original.email);
  });

  group('firstName', () {
    test('a keresztnév első szava', () {
      final user = LdapUser.fromJson({...validJson(), 'givenName': 'Elek János'});
      expect(user.firstName, 'Elek');
    });

    test('üres keresztnévnél a login', () {
      final user = LdapUser.fromJson({...validJson(), 'givenName': ''});
      expect(user.firstName, 'perpa4');
    });
  });

  test('a nem objektum FormatException', () {
    expect(() => LdapUser.parse(null), throwsFormatException);
  });
}
