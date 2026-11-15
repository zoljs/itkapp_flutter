import 'package:flutter_test/flutter_test.dart';
import 'package:itk_app/utils/semester.dart';

void main() {
  group('currentSemester', () {
    final cases = <DateTime, String>{
      DateTime(2026, 8, 1): '2026/27/1', // első őszi nap
      DateTime(2026, 11, 4): '2026/27/1',
      DateTime(2026, 12, 31): '2026/27/1',
      DateTime(2027, 1, 15): '2026/27/1', // a januári vizsgaidőszak az őszé
      DateTime(2027, 2, 1): '2026/27/2', // első tavaszi nap
      DateTime(2027, 7, 31): '2026/27/2',
    };
    for (final entry in cases.entries) {
      test('${entry.key} -> ${entry.value}', () {
        expect(currentSemester(entry.key), entry.value);
      });
    }

    test('az évszázad fordulóján a záró év két számjegye 00', () {
      expect(currentSemester(DateTime(2099, 9, 1)), '2099/00/1');
    });
  });

  group('recentSemesters', () {
    test('ősztől visszafelé, félévenként', () {
      expect(
        recentSemesters(count: 4, now: DateTime(2026, 11, 4)),
        ['2026/27/1', '2025/26/2', '2025/26/1', '2024/25/2'],
      );
    });

    test('tavasztól visszafelé', () {
      expect(
        recentSemesters(count: 3, now: DateTime(2027, 3, 1)),
        ['2026/27/2', '2026/27/1', '2025/26/2'],
      );
    });

    test('alapból 12 félévet ad, az első az aktuális', () {
      final now = DateTime(2026, 11, 4);

      final result = recentSemesters(now: now);

      expect(result, hasLength(12));
      expect(result.first, currentSemester(now));
      expect(result.toSet(), hasLength(12));
    });

    test('count: 1 csak az aktuális félév', () {
      expect(recentSemesters(count: 1, now: DateTime(2026, 11, 4)),
          ['2026/27/1']);
    });
  });

  group('semesterLabel', () {
    test('ősz', () => expect(semesterLabel('2026/27/1'), '2026/27 ősz'));
    test('tavasz', () => expect(semesterLabel('2026/27/2'), '2026/27 tavasz'));

    test('ismeretlen félévszám változatlanul marad', () {
      expect(semesterLabel('2026/27/3'), '2026/27 3');
    });

    test('hibás formátum változatlanul visszajön', () {
      expect(semesterLabel('2026/27'), '2026/27');
      expect(semesterLabel('valami'), 'valami');
    });
  });
}
