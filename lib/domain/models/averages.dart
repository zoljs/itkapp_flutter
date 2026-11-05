import 'dart:convert';

import 'package:itk_app/domain/models/absolutorium.dart';

const kCreditsPerSemester = 30;

class SemesterStats {
  const SemesterStats({
    required this.semester,
    required this.enrolledCredits,
    required this.completedCredits,
    required this.weightedAverage,
    required this.creditIndex,
    required this.correctedCreditIndex,
  });

  final String semester;
  final int enrolledCredits;
  final int completedCredits;
  final double? weightedAverage;
  final double creditIndex;
  final double correctedCreditIndex;
}

class AverageSummary {
  const AverageSummary({
    required this.semesters,
    required this.overallWeightedAverage,
    required this.diplomaWeightedAverage,
    required this.cumulativeCorrectedCreditIndex,
    required this.totalEnrolledCredits,
    required this.totalCompletedCredits,
    required this.lowestGrade,
    required this.hasFailedSubject,
  });

  static const empty = AverageSummary(
    semesters: [],
    overallWeightedAverage: null,
    diplomaWeightedAverage: null,
    cumulativeCorrectedCreditIndex: 0,
    totalEnrolledCredits: 0,
    totalCompletedCredits: 0,
    lowestGrade: null,
    hasFailedSubject: false,
  );

  final List<SemesterStats> semesters;
  final double? overallWeightedAverage;
  final double? diplomaWeightedAverage;
  final double cumulativeCorrectedCreditIndex;
  final int totalEnrolledCredits;
  final int totalCompletedCredits;
  final int? lowestGrade;
  final bool hasFailedSubject;

  int get activeSemesters => semesters.length;

  SemesterStats? get latest => semesters.isEmpty ? null : semesters.first;

  SemesterStats? forSemester(String semester) {
    for (final s in semesters) {
      if (s.semester == semester) return s;
    }
    return null;
  }

  bool get isEmpty => semesters.isEmpty;
}

bool isThesisSubjectName(String name) {
  final n = name.toLowerCase();
  return n.contains('szakdolgozat') ||
      n.contains('diplomamunka') ||
      n.contains('diplomadolgozat') ||
      n.contains('thesis work');
}

class _Acc {
  int enrolled = 0;
  int completed = 0;
  int passedGradedCredits = 0;
  int passedWeighted = 0;

  void add(Completion c) {
    enrolled += c.credits;
    if (c.isPassing) completed += c.credits;
    final grade = c.grade;
    if (grade == null || grade < 2) return;
    passedGradedCredits += c.credits;
    passedWeighted += c.credits * grade;
  }

  double? get weightedAverage =>
      passedGradedCredits == 0 ? null : passedWeighted / passedGradedCredits;
}

SemesterStats _stats(String semester, _Acc acc) {
  final ki = acc.passedWeighted / kCreditsPerSemester;
  return SemesterStats(
    semester: semester,
    enrolledCredits: acc.enrolled,
    completedCredits: acc.completed,
    weightedAverage: acc.weightedAverage,
    creditIndex: ki,
    correctedCreditIndex:
        acc.enrolled == 0 ? 0 : ki * acc.completed / acc.enrolled,
  );
}

AverageSummary computeAverages(Iterable<Completion> completions) {
  final bySemester = <String, _Acc>{};
  final total = _Acc();
  final diploma = _Acc();
  int? lowest;

  for (final c in completions) {
    bySemester.putIfAbsent(c.semester, _Acc.new).add(c);
    total.add(c);
    if (!isThesisSubjectName(c.name)) diploma.add(c);
    final grade = c.grade;
    if (grade != null && (lowest == null || grade < lowest)) lowest = grade;
  }

  final keys = bySemester.keys.toList()..sort((a, b) => b.compareTo(a));
  final semesters = [for (final key in keys) _stats(key, bySemester[key]!)];

  final active = semesters.length;
  final cumulativeCki = active == 0 || total.enrolled == 0
      ? 0.0
      : total.passedWeighted /
          (kCreditsPerSemester * active) *
          total.completed /
          total.enrolled;

  return AverageSummary(
    semesters: List.unmodifiable(semesters),
    overallWeightedAverage: total.weightedAverage,
    diplomaWeightedAverage: diploma.weightedAverage,
    cumulativeCorrectedCreditIndex: cumulativeCki,
    totalEnrolledCredits: total.enrolled,
    totalCompletedCredits: total.completed,
    lowestGrade: lowest,
    hasFailedSubject: lowest == 1,
  );
}

String formatAverage(double? value) =>
    value == null ? '–' : value.toStringAsFixed(2).replaceAll('.', ',');

double truncateTo2(double value) => (value * 100 + 1e-9).floorToDouble() / 100;

class DiplomaInputs {
  const DiplomaInputs({this.thesis, this.finalExam});

  static const empty = DiplomaInputs();

  final int? thesis;
  final int? finalExam;

  DiplomaInputs withThesis(int? v) =>
      DiplomaInputs(thesis: v, finalExam: finalExam);
  DiplomaInputs withFinalExam(int? v) =>
      DiplomaInputs(thesis: thesis, finalExam: v);

  String toJsonString() =>
      jsonEncode({'thesis': thesis, 'finalExam': finalExam});

  static DiplomaInputs fromJsonString(String? raw) {
    if (raw == null) return empty;
    try {
      final data = jsonDecode(raw);
      if (data is! Map<String, dynamic>) return empty;
      int? grade(Object? v) => v is int && v >= 1 && v <= 5 ? v : null;
      return DiplomaInputs(
          thesis: grade(data['thesis']), finalExam: grade(data['finalExam']));
    } on FormatException {
      return empty;
    }
  }
}

class DiplomaPart {
  const DiplomaPart(
      {required this.label,
      required this.weight,
      required this.value,
      required this.estimated});

  final String label;
  final double weight;
  final double value;
  final bool estimated;
}

class DiplomaEstimate {
  const DiplomaEstimate({required this.value, required this.parts});

  final double value;
  final List<DiplomaPart> parts;

  bool get isEstimate => parts.any((p) => p.estimated);

  String get classification {
    if (value >= 4.5) return 'jeles';
    if (value >= 3.5) return 'jó';
    if (value >= 2.5) return 'közepes';
    if (value >= 2) return 'elégséges';
    return 'elégtelen';
  }
}

DiplomaEstimate? estimateDiploma(
    double? weightedAverage, DiplomaInputs inputs) {
  if (weightedAverage == null) return null;

  DiplomaPart part(String label, double weight, int? grade) => DiplomaPart(
        label: label,
        weight: weight,
        value: grade == null ? weightedAverage : grade.toDouble(),
        estimated: grade == null,
      );

  final parts = [
    part('Szakdolgozat / diplomamunka', 0.40, inputs.thesis),
    part('Záróvizsga tárgy', 0.30, inputs.finalExam),
    DiplomaPart(
        label: 'Súlyozott tanulmányi átlag',
        weight: 0.30,
        value: weightedAverage,
        estimated: false),
  ];

  final raw = parts.fold<double>(0, (sum, p) => sum + p.weight * p.value);
  return DiplomaEstimate(
      value: truncateTo2(raw), parts: List.unmodifiable(parts));
}

class HonoursCondition {
  const HonoursCondition(this.label, this.met);

  final String label;
  final bool? met;
}

List<HonoursCondition> honoursConditions(
    AverageSummary averages, DiplomaInputs inputs) {
  final avg = averages.overallWeightedAverage;
  return [
    HonoursCondition('Záróvizsga tárgy jeles',
        inputs.finalExam == null ? null : inputs.finalExam == 5),
    HonoursCondition('Szakdolgozat / diplomamunka jeles',
        inputs.thesis == null ? null : inputs.thesis == 5),
    HonoursCondition('Súlyozott tanulmányi átlag legalább 4,00',
        avg == null ? null : avg >= 4),
    HonoursCondition(
      'Nincs közepesnél rosszabb jegy',
      averages.lowestGrade == null ? null : averages.lowestGrade! >= 3,
    ),
    HonoursCondition('Nincs nem teljesített tárgy',
        averages.isEmpty ? null : !averages.hasFailedSubject),
  ];
}
