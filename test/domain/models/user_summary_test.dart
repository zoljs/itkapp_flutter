import 'package:flutter_test/flutter_test.dart';
import 'package:itk_app/domain/models/user_summary.dart';

Map<String, dynamic> validJson() => {'userId': 7, 'fullName': 'Teszt Elek', 'ldapUsername': 'tesel1'};

void main() {
  test('beolvassa', () {
    final user = UserSummary.fromJson(validJson());
    expect(user.userId, 7);
    expect(user.fullName, 'Teszt Elek');
    expect(user.ldapUsername, 'tesel1');
  });

  final invalid = <String, Map<String, dynamic>>{
    'hiányzik az id': {...validJson()}..remove('userId'),
    'üres a név': {...validJson(), 'fullName': ' '},
    'üres a felhasználónév': {...validJson(), 'ldapUsername': ''},
  };
  for (final entry in invalid.entries) {
    test('FormatException, ha ${entry.key}', () {
      expect(() => UserSummary.fromJson(entry.value), throwsFormatException);
    });
  }

  test('a nem lista és a nem objektum elem FormatException', () {
    expect(() => UserSummary.parseList('x'), throwsFormatException);
    expect(() => UserSummary.parseList([validJson(), 'x']), throwsFormatException);
  });
}
