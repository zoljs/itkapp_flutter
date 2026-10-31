import 'package:flutter_test/flutter_test.dart';
import 'package:itk_app/domain/models/absolutorium.dart';
import 'package:itk_app/domain/models/averages.dart';

Completion c(int id, String semester, int credits, int? grade, {bool custom = false, String? name}) => Completion(
  id: id,
  subjectId: custom ? null : id,
  code: custom ? null : 'K$id',
  name: name ?? 'Tárgy $id',
  credits: credits,
  requirementType: grade == null ? 'Aláírás' : 'Vizsga',
  isCustom: custom,
  semester: semester,
  grade: grade,
);

final sample = [
  c(1, '2025/26/1', 5, 5),
  c(2, '2025/26/1', 4, 3),
  c(3, '2025/26/1', 3, 1),
  c(4, '2025/26/1', 2, null),
  c(5, '2025/26/1', 3, 4, custom: true),
  c(6, '2024/25/2', 6, 4),
];

void main() {
  group('computeAverages (TVSZ 38. §)', () {
    test('empty list', () {
      final a = computeAverages(const []);
      expect(a.isEmpty, isTrue);
      expect(a.overallWeightedAverage, isNull);
      expect(a.latest, isNull);
      expect(a.cumulativeCorrectedCreditIndex, 0);
    });

    test('per-semester stats, newest first', () {
      final a = computeAverages(sample);
      expect(a.semesters.map((s) => s.semester), ['2025/26/1', '2024/25/2']);

      final s = a.latest!;
      expect(s.enrolledCredits, 17);
      expect(s.completedCredits, 14);
      expect(s.weightedAverage, closeTo(49 / 12, 1e-9));
      expect(s.creditIndex, closeTo(49 / 30, 1e-9));
      expect(s.correctedCreditIndex, closeTo(49 / 30 * 14 / 17, 1e-9));

      final older = a.forSemester('2024/25/2')!;
      expect(older.weightedAverage, 4);
      expect(older.creditIndex, closeTo(0.8, 1e-9));
      expect(older.correctedCreditIndex, closeTo(0.8, 1e-9));
    });

    test('cumulative average excludes failed and signature-only subjects', () {
      final a = computeAverages(sample);
      expect(a.overallWeightedAverage, closeTo(73 / 18, 1e-9));
      expect(a.totalEnrolledCredits, 23);
      expect(a.totalCompletedCredits, 20);
      expect(a.cumulativeCorrectedCreditIndex, closeTo(73 / 60 * 20 / 23, 1e-9));
      expect(a.lowestGrade, 1);
      expect(a.hasFailedSubject, isTrue);
    });

    test('diploma average excludes thesis subjects', () {
      final a = computeAverages([
        c(1, '2025/26/1', 6, 4),
        c(2, '2025/26/2', 15, 5, name: 'Szakdolgozat MI-BSc'),
      ]);
      expect(a.overallWeightedAverage, closeTo(99 / 21, 1e-9));
      expect(a.diplomaWeightedAverage, 4);
    });

    test('signature-only semester has no average', () {
      final a = computeAverages([c(1, '2025/26/1', 0, null)]);
      expect(a.latest!.weightedAverage, isNull);
      expect(a.latest!.correctedCreditIndex, 0);
    });
  });

  group('estimateDiploma (TVSZ 1. sz. melléklet 16. §)', () {
    test('null without average', () {
      expect(estimateDiploma(null, DiplomaInputs.empty), isNull);
    });

    test('missing parts are estimated with the average, result truncated', () {
      const avg = 73 / 18;
      final e = estimateDiploma(avg, const DiplomaInputs(thesis: 5))!;
      expect(e.isEstimate, isTrue);
      expect(e.value, 4.43);
      expect(e.classification, 'jó');
    });

    test('all parts given', () {
      const avg = 73 / 18;
      final e = estimateDiploma(avg, const DiplomaInputs(thesis: 5, finalExam: 5))!;
      expect(e.isEstimate, isFalse);
      expect(e.value, 4.71);
      expect(e.classification, 'jeles');
    });

    test('truncateTo2', () {
      expect(truncateTo2(4.499), 4.49);
      expect(truncateTo2(4.3), 4.3);
      expect(truncateTo2(4.5), 4.5);
    });
  });

  test('honoursConditions', () {
    final a = computeAverages(sample);
    final list = honoursConditions(a, const DiplomaInputs(thesis: 5, finalExam: 5));
    expect(list.map((h) => h.met), [true, true, true, false, false]);

    final unknown = honoursConditions(AverageSummary.empty, DiplomaInputs.empty);
    expect(unknown.every((h) => h.met == null), isTrue);
  });

  group('DiplomaInputs json', () {
    test('round trip, old mathExam key ignored, invalid values', () {
      const inputs = DiplomaInputs(thesis: 4);
      final back = DiplomaInputs.fromJsonString(inputs.toJsonString());
      expect(back.thesis, 4);
      expect(back.finalExam, isNull);

      expect(DiplomaInputs.fromJsonString('{"thesis":5,"mathExam":3}').thesis, 5);
      expect(DiplomaInputs.fromJsonString('{"thesis":9}').thesis, isNull);
      expect(DiplomaInputs.fromJsonString('nem json').thesis, isNull);
      expect(DiplomaInputs.fromJsonString(null).thesis, isNull);
    });
  });

  test('formatAverage', () {
    expect(formatAverage(null), '–');
    expect(formatAverage(49 / 12), '4,08');
  });
}