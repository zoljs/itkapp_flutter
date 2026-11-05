import 'package:flutter_test/flutter_test.dart';
import 'package:itk_app/utils/time_range.dart';

void main() {
  // Thursday
  final now = DateTime(2026, 11, 5, 12);

  group('TimeRange.thisWeek', () {
    test('Monday 00:00 is inside', () {
      expect(TimeRange.thisWeek.contains(DateTime(2026, 11, 2), now: now),
          isTrue);
    });
    test('Sunday 23:59 is inside', () {
      expect(
          TimeRange.thisWeek
              .contains(DateTime(2026, 11, 8, 23, 59), now: now),
          isTrue);
    });
    test('previous Sunday 23:59 is outside', () {
      expect(
          TimeRange.thisWeek
              .contains(DateTime(2026, 11, 1, 23, 59), now: now),
          isFalse);
    });
    test('next Monday 00:00 is outside', () {
      expect(TimeRange.thisWeek.contains(DateTime(2026, 11, 9), now: now),
          isFalse);
    });
    test('week crossing a month boundary', () {
      final wed = DateTime(2026, 12, 2);
      expect(TimeRange.thisWeek.contains(DateTime(2026, 11, 30), now: wed),
          isTrue);
      expect(TimeRange.thisWeek.contains(DateTime(2026, 12, 6), now: wed),
          isTrue);
      expect(TimeRange.thisWeek.contains(DateTime(2026, 11, 29), now: wed),
          isFalse);
      expect(TimeRange.thisWeek.contains(DateTime(2026, 12, 7), now: wed),
          isFalse);
    });
    test('a UTC date is compared as the same instant', () {
      final monday = DateTime(2026, 11, 2);
      expect(TimeRange.thisWeek.contains(monday.toUtc(), now: now), isTrue);
      expect(
          TimeRange.thisWeek.contains(
              monday.subtract(const Duration(microseconds: 1)).toUtc(),
              now: now),
          isFalse);
    });
  });

  group('TimeRange.thisMonth', () {
    test('first day 00:00 is inside', () {
      expect(TimeRange.thisMonth.contains(DateTime(2026, 11, 1), now: now),
          isTrue);
    });
    test('last day 23:59 is inside', () {
      expect(
          TimeRange.thisMonth
              .contains(DateTime(2026, 11, 30, 23, 59), now: now),
          isTrue);
    });
    test('previous month last minute is outside', () {
      expect(
          TimeRange.thisMonth
              .contains(DateTime(2026, 10, 31, 23, 59), now: now),
          isFalse);
    });
    test('next month first day is outside', () {
      expect(TimeRange.thisMonth.contains(DateTime(2026, 12, 1), now: now),
          isFalse);
    });
    test('December ends on 2027-01-01', () {
      final dec = DateTime(2026, 12, 15);
      expect(
          TimeRange.thisMonth
              .contains(DateTime(2026, 12, 31, 23, 59), now: dec),
          isTrue);
      expect(TimeRange.thisMonth.contains(DateTime(2027, 1, 1), now: dec),
          isFalse);
    });
  });
}
