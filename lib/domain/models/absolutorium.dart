T _req<T>(Map<String, dynamic> json, String key, String what) {
  final v = json[key];
  if (v is T) return v;
  throw FormatException('Hibás vagy hiányzó mező: $what ($key).');
}

T? _opt<T>(Map<String, dynamic> json, String key, String what) {
  final v = json[key];
  if (v == null) return null;
  if (v is T) return v;
  throw FormatException('Hibás mező: $what ($key).');
}

int _int(Map<String, dynamic> json, String key, String what) {
  final v = json[key];
  if (v is int) return v;
  if (v is num) return v.toInt();
  throw FormatException('Hibás vagy hiányzó szám: $what ($key).');
}

int? _optInt(Map<String, dynamic> json, String key, String what) =>
    json[key] == null ? null : _int(json, key, what);

Map<String, dynamic> _map(Object? data, String what) {
  if (data is Map<String, dynamic>) return data;
  throw FormatException('$what nem objektum formátumú.');
}

List<T> _list<T>(
    Object? data, String what, T Function(Map<String, dynamic>) fromJson) {
  if (data is! List) throw FormatException('$what nem lista formátumú.');
  return List.unmodifiable(data.map((e) => fromJson(_map(e, what))));
}

enum SubgroupType {
  mandatory('MANDATORY', 'Kötelező'),
  elective('ELECTIVE', 'Köt. vál.'),
  freeElective('FREE_ELECTIVE', 'Szabadon vál.');

  const SubgroupType(this.apiValue, this.label);

  final String apiValue;
  final String label;

  static SubgroupType parse(Object? value) {
    for (final t in values) {
      if (t.apiValue == value) return t;
    }
    throw FormatException('Ismeretlen tárgycsoport-típus: $value');
  }
}

String gradeLabel(int? grade) => grade == null ? 'aláírás' : '$grade';

bool isSignatureOnly(String? requirementType) =>
    requirementType?.toLowerCase().startsWith('aláírás') ?? false;

class SpecializationOption {
  const SpecializationOption(
      {required this.id, required this.name, this.requiredCredits});

  final int id;
  final String name;
  final int? requiredCredits;

  factory SpecializationOption.fromJson(Map<String, dynamic> json) =>
      SpecializationOption(
        id: _int(json, 'id', 'specializáció id'),
        name: _req<String>(json, 'name', 'specializáció neve'),
        requiredCredits:
            _optInt(json, 'requiredCredits', 'specializáció kredit'),
      );
}

class CurriculumOption {
  const CurriculumOption({
    required this.id,
    required this.code,
    required this.name,
    required this.major,
    required this.totalCreditsRequired,
    required this.specializations,
  });

  final int id;
  final String code;
  final String name;
  final String major;
  final int totalCreditsRequired;
  final List<SpecializationOption> specializations;

  factory CurriculumOption.fromJson(Map<String, dynamic> json) =>
      CurriculumOption(
        id: _int(json, 'id', 'tanterv id'),
        code: _req<String>(json, 'code', 'tantervkód'),
        name: _req<String>(json, 'name', 'tanterv neve'),
        major: _req<String>(json, 'major', 'szak'),
        totalCreditsRequired:
            _int(json, 'totalCreditsRequired', 'szükséges kredit'),
        specializations: _list(json['specializations'],
            'A specializációk listája', SpecializationOption.fromJson),
      );

  static List<CurriculumOption> parseList(Object? data) =>
      _list(data, 'A tantervlista', CurriculumOption.fromJson);
}

class CompletedSubject {
  const CompletedSubject({
    required this.completionId,
    required this.subjectId,
    required this.code,
    required this.name,
    required this.credits,
    required this.grade,
    required this.semester,
    required this.isCustom,
    required this.countedAsFreeElective,
  });

  final int? completionId;

  final int? subjectId;

  final String? code;
  final String name;
  final int credits;
  final int? grade;
  final String semester;
  final bool isCustom;
  final bool countedAsFreeElective;

  factory CompletedSubject.fromJson(Map<String, dynamic> json) =>
      CompletedSubject(
        completionId: _optInt(json, 'completionId', 'teljesítés id'),
        subjectId: _optInt(json, 'subjectId', 'tárgy id'),
        code: _opt<String>(json, 'code', 'tárgykód'),
        name: _req<String>(json, 'name', 'tárgynév'),
        credits: _int(json, 'credits', 'kredit'),
        grade: _optInt(json, 'grade', 'jegy'),
        semester: _req<String>(json, 'semester', 'félév'),
        isCustom: _opt<bool>(json, 'isCustom', 'saját tárgy') ?? false,
        countedAsFreeElective:
            _opt<bool>(json, 'countedAsFreeElective', 'szabvál.') ?? false,
      );
}

class MissingSubject {
  const MissingSubject({
    required this.subjectId,
    required this.code,
    required this.name,
    required this.credits,
    required this.recommendedSemester,
  });

  final int subjectId;
  final String code;
  final String name;
  final int credits;
  final int? recommendedSemester;

  factory MissingSubject.fromJson(Map<String, dynamic> json) => MissingSubject(
        subjectId: _int(json, 'subjectId', 'tárgy id'),
        code: _req<String>(json, 'code', 'tárgykód'),
        name: _req<String>(json, 'name', 'tárgynév'),
        credits: _int(json, 'credits', 'kredit'),
        recommendedSemester:
            _optInt(json, 'recommendedSemester', 'ajánlott félév'),
      );
}

class SubgroupProgress {
  const SubgroupProgress({
    required this.id,
    required this.name,
    required this.type,
    required this.requiredCredits,
    required this.requiredCount,
    required this.earnedCredits,
    required this.countedCredits,
    required this.remainingCredits,
    required this.completedCount,
    required this.overflowCredits,
    required this.receivedOverflowCredits,
    required this.isComplete,
    required this.completed,
    required this.missing,
  });

  final int id;
  final String name;
  final SubgroupType type;
  final int requiredCredits;
  final int? requiredCount;
  final int earnedCredits;
  final int countedCredits;
  final int remainingCredits;
  final int completedCount;
  final int overflowCredits;
  final int receivedOverflowCredits;
  final bool isComplete;
  final List<CompletedSubject> completed;
  final List<MissingSubject> missing;

  factory SubgroupProgress.fromJson(Map<String, dynamic> json) =>
      SubgroupProgress(
        id: _int(json, 'id', 'tárgycsoport id'),
        name: _req<String>(json, 'name', 'tárgycsoport neve'),
        type: SubgroupType.parse(json['type']),
        requiredCredits: _int(json, 'requiredCredits', 'elvárt kredit'),
        requiredCount: _optInt(json, 'requiredCount', 'elvárt darabszám'),
        earnedCredits: _int(json, 'earnedCredits', 'szerzett kredit'),
        countedCredits: _int(json, 'countedCredits', 'beszámított kredit'),
        remainingCredits: _int(json, 'remainingCredits', 'hiányzó kredit'),
        completedCount: _int(json, 'completedCount', 'teljesített db'),
        overflowCredits: _int(json, 'overflowCredits', 'többlet'),
        receivedOverflowCredits:
            _int(json, 'receivedOverflowCredits', 'átvett többlet'),
        isComplete: _req<bool>(json, 'isComplete', 'kész'),
        completed: _list(json['completed'], 'A teljesített tárgyak listája',
            CompletedSubject.fromJson),
        missing: _list(json['missing'], 'A hiányzó tárgyak listája',
            MissingSubject.fromJson),
      );
}

class GroupProgress {
  const GroupProgress({
    required this.id,
    required this.name,
    required this.isSpecialization,
    required this.requiredCredits,
    required this.requiredSubgroupCount,
    required this.earnedCredits,
    required this.countedCredits,
    required this.remainingCredits,
    required this.completedSubgroupCount,
    required this.isComplete,
    required this.subgroups,
  });

  final int id;
  final String name;
  final bool isSpecialization;
  final int requiredCredits;
  final int requiredSubgroupCount;
  final int earnedCredits;
  final int countedCredits;
  final int remainingCredits;
  final int completedSubgroupCount;
  final bool isComplete;
  final List<SubgroupProgress> subgroups;

  int get missingMandatoryCount =>
      subgroups.fold(0, (sum, s) => sum + s.missing.length);

  factory GroupProgress.fromJson(Map<String, dynamic> json) => GroupProgress(
        id: _int(json, 'id', 'csoport id'),
        name: _req<String>(json, 'name', 'csoport neve'),
        isSpecialization:
            _req<bool>(json, 'isSpecialization', 'specializáció-e'),
        requiredCredits: _int(json, 'requiredCredits', 'elvárt kredit'),
        requiredSubgroupCount:
            _int(json, 'requiredSubgroupCount', 'elvárt tárgycsoport'),
        earnedCredits: _int(json, 'earnedCredits', 'szerzett kredit'),
        countedCredits: _int(json, 'countedCredits', 'beszámított kredit'),
        remainingCredits: _int(json, 'remainingCredits', 'hiányzó kredit'),
        completedSubgroupCount:
            _int(json, 'completedSubgroupCount', 'kész tárgycsoport'),
        isComplete: _req<bool>(json, 'isComplete', 'kész'),
        subgroups: _list(json['subgroups'], 'A tárgycsoportok listája',
            SubgroupProgress.fromJson),
      );
}

class TypeTotals {
  const TypeTotals(
      {required this.earnedCredits,
      required this.requiredCredits,
      required this.countedCredits});

  final int earnedCredits;
  final int requiredCredits;
  final int countedCredits;

  factory TypeTotals.fromJson(Map<String, dynamic> json) => TypeTotals(
        earnedCredits: _int(json, 'earnedCredits', 'szerzett kredit'),
        requiredCredits: _int(json, 'requiredCredits', 'elvárt kredit'),
        countedCredits: _int(json, 'countedCredits', 'beszámított kredit'),
      );
}

class CurriculumInfo {
  const CurriculumInfo({
    required this.id,
    required this.code,
    required this.name,
    required this.major,
    required this.totalCreditsRequired,
  });

  final int id;
  final String code;
  final String name;
  final String major;
  final int totalCreditsRequired;

  factory CurriculumInfo.fromJson(Map<String, dynamic> json) => CurriculumInfo(
        id: _int(json, 'id', 'tanterv id'),
        code: _req<String>(json, 'code', 'tantervkód'),
        name: _req<String>(json, 'name', 'tanterv neve'),
        major: _req<String>(json, 'major', 'szak'),
        totalCreditsRequired:
            _int(json, 'totalCreditsRequired', 'szükséges kredit'),
      );
}

class AbsolutoriumProgress {
  const AbsolutoriumProgress({
    required this.curriculum,
    required this.chosenSpecializationId,
    required this.specializationOptions,
    required this.earnedCredits,
    required this.requiredCredits,
    required this.remainingCredits,
    required this.percent,
    required this.byType,
    required this.groups,
    required this.uncategorized,
    required this.isComplete,
  });

  final CurriculumInfo curriculum;
  final int? chosenSpecializationId;
  final List<SpecializationOption> specializationOptions;
  final int earnedCredits;
  final int requiredCredits;
  final int remainingCredits;
  final int percent;
  final Map<SubgroupType, TypeTotals> byType;
  final List<GroupProgress> groups;
  final List<CompletedSubject> uncategorized;
  final bool isComplete;

  bool get needsSpecialization =>
      specializationOptions.isNotEmpty && chosenSpecializationId == null;

  SpecializationOption? get chosenSpecialization {
    for (final s in specializationOptions) {
      if (s.id == chosenSpecializationId) return s;
    }
    return null;
  }

  GroupProgress? groupById(int id) {
    for (final g in groups) {
      if (g.id == id) return g;
    }
    return null;
  }

  factory AbsolutoriumProgress.fromJson(Map<String, dynamic> json) {
    final spec = _map(json['specialization'], 'A specializáció');
    final totals = _map(json['totals'], 'Az összesítő');
    final byType = _map(json['byType'], 'A típusonkénti összesítő');

    return AbsolutoriumProgress(
      curriculum:
          CurriculumInfo.fromJson(_map(json['curriculum'], 'A tanterv')),
      chosenSpecializationId: _optInt(spec, 'chosenId', 'választott spec.'),
      specializationOptions: _list(spec['options'], 'A specializációk listája',
          SpecializationOption.fromJson),
      earnedCredits: _int(totals, 'earnedCredits', 'szerzett kredit'),
      requiredCredits: _int(totals, 'requiredCredits', 'szükséges kredit'),
      remainingCredits: _int(totals, 'remainingCredits', 'hiányzó kredit'),
      percent: _int(totals, 'percent', 'százalék'),
      byType: {
        for (final t in SubgroupType.values)
          t: TypeTotals.fromJson(
              _map(byType[t.apiValue], 'A(z) ${t.label} összesítő')),
      },
      groups:
          _list(json['groups'], 'A csoportok listája', GroupProgress.fromJson),
      uncategorized: _list(json['uncategorized'],
          'A nem besorolt tárgyak listája', CompletedSubject.fromJson),
      isComplete: _req<bool>(json, 'isComplete', 'abszolutórium kész'),
    );
  }

  static AbsolutoriumProgress parse(Object? data) =>
      AbsolutoriumProgress.fromJson(_map(data, 'A haladás'));
}

class Completion {
  const Completion({
    required this.id,
    required this.subjectId,
    required this.code,
    required this.name,
    required this.credits,
    required this.requirementType,
    required this.isCustom,
    required this.semester,
    required this.grade,
  });

  final int id;

  final int? subjectId;
  final String? code;
  final String name;
  final int credits;
  final String? requirementType;
  final bool isCustom;
  final String semester;
  final int? grade;

  bool get isPassing => grade == null || grade! >= 2;

  factory Completion.fromJson(Map<String, dynamic> json) => Completion(
        id: _int(json, 'id', 'teljesítés id'),
        subjectId: _optInt(json, 'subjectId', 'tárgy id'),
        code: _opt<String>(json, 'code', 'tárgykód'),
        name: _req<String>(json, 'name', 'tárgynév'),
        credits: _int(json, 'credits', 'kredit'),
        requirementType: _opt<String>(json, 'requirementType', 'követelmény'),
        isCustom: _opt<bool>(json, 'isCustom', 'saját tárgy') ?? false,
        semester: _req<String>(json, 'semester', 'félév'),
        grade: _optInt(json, 'grade', 'jegy'),
      );

  static List<Completion> parseList(Object? data) =>
      _list(data, 'A teljesítések listája', Completion.fromJson);
}

class CurriculumSubject {
  const CurriculumSubject({
    required this.id,
    required this.code,
    required this.name,
    required this.credits,
    required this.requirementType,
  });

  final int id;
  final String code;
  final String name;
  final int credits;
  final String? requirementType;

  List<int?> get gradeOptions {
    if (isSignatureOnly(requirementType)) return const [null];
    if (requirementType == null) return const [5, 4, 3, 2, 1, null];
    return const [5, 4, 3, 2, 1];
  }

  factory CurriculumSubject.fromJson(Map<String, dynamic> json) =>
      CurriculumSubject(
        id: _int(json, 'id', 'tárgy id'),
        code: _req<String>(json, 'code', 'tárgykód'),
        name: _req<String>(json, 'name', 'tárgynév'),
        credits: _int(json, 'credits', 'kredit'),
        requirementType: _opt<String>(json, 'requirementType', 'követelmény'),
      );

  static List<CurriculumSubject> parseList(Object? data) =>
      _list(data, 'A tárgylista', CurriculumSubject.fromJson);
}
