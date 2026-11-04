import 'package:flutter_test/flutter_test.dart';
import 'package:itk_app/utils/semester.dart';

void main() {
  group('currentSemesterStart', () {
    final cases = <DateTime, DateTime>{
      DateTime(2026, 11, 4): DateTime(2026, 8, 1), // fall, during classes
      DateTime(2026, 8, 1): DateTime(2026, 8, 1), // first day of fall
      DateTime(2027, 1, 15): DateTime(2026, 8, 1), // January exams belong to fall
      DateTime(2027, 2, 1): DateTime(2027, 2, 1), // first day of spring
      DateTime(2027, 6, 20): DateTime(2027, 2, 1), // spring exams
      DateTime(2027, 7, 31): DateTime(2027, 2, 1), // last day of spring
    };
    for (final entry in cases.entries) {
      test('${entry.key} -> ${entry.value}', () {
        expect(currentSemesterStart(entry.key), entry.value);
      });
    }

    test('matches currentSemester (same rule)', () {
      for (final now in cases.keys) {
        final start = currentSemesterStart(now);
        expect(currentSemester(now), currentSemester(start), reason: '$now');
      }
    });
  });
}
