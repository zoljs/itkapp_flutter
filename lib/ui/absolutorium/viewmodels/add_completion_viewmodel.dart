import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:itk_app/data/repositories/absolutorium_repository.dart';
import 'package:itk_app/domain/models/absolutorium.dart';
import 'package:itk_app/utils/command.dart';
import 'package:itk_app/utils/result.dart';
import 'package:itk_app/utils/semester.dart';

class AddCompletionViewModel extends ChangeNotifier {
  AddCompletionViewModel(
      {required AbsolutoriumRepository repository,
      MissingSubject? initialSubject})
      : _repository = repository,
        lockedToCurriculum = initialSubject != null {
    save = Command0<void>(_save);
    if (initialSubject != null) {
      _subject = CurriculumSubject(
        id: initialSubject.subjectId,
        code: initialSubject.code,
        name: initialSubject.name,
        credits: initialSubject.credits,
        requirementType: null,
      );
      unawaited(_resolveRequirementType(initialSubject));
    }
  }

  static const allGrades = <int?>[5, 4, 3, 2, 1, null];
  static const maxCustomCredits = 30;

  final AbsolutoriumRepository _repository;
  late final Command0<void> save;

  final bool lockedToCurriculum;

  @override
  void dispose() {
    save.dispose();
    super.dispose();
  }

  bool _custom = false;
  CurriculumSubject? _subject;
  String _customName = '';
  String _customCode = '';
  int _customCredits = 3;
  String _semester = currentSemester();
  int? _grade = 5;

  bool get custom => _custom;

  CurriculumSubject? get subject => _subject;

  String get customName => _customName;

  int get customCredits => _customCredits;

  String get semester => _semester;

  int? get grade => _grade;

  List<int?> get gradeOptions =>
      _custom ? allGrades : (_subject?.gradeOptions ?? allGrades);

  bool get canSave {
    if (save.running) return false;
    return _custom ? _customName.trim().length >= 2 : _subject != null;
  }

  void setCustom(bool value) {
    if (value == _custom) return;
    _custom = value;
    _fixGrade();
    notifyListeners();
  }

  void setSubject(CurriculumSubject value) {
    _subject = value;
    _fixGrade();
    notifyListeners();
  }

  void switchToCustomWithName(String name) {
    _customName = name;
    _custom = true;
    _fixGrade();
    notifyListeners();
  }

  void setCustomName(String value) {
    _customName = value;
    notifyListeners();
  }

  void setCustomCode(String value) {
    _customCode = value;
    notifyListeners();
  }

  void changeCustomCredits(int delta) {
    _customCredits = (_customCredits + delta).clamp(0, maxCustomCredits);
    notifyListeners();
  }

  void setSemester(String value) {
    _semester = value;
    notifyListeners();
  }

  void setGrade(int? value) {
    _grade = value;
    notifyListeners();
  }

  void _fixGrade() {
    if (!gradeOptions.contains(_grade)) _grade = gradeOptions.first;
  }

  Future<void> _resolveRequirementType(MissingSubject s) async {
    final result = await _repository.searchSubjects(s.code);
    if (result case Ok(:final value)) {
      for (final hit in value) {
        if (hit.id == s.subjectId) {
          setSubject(hit);
          return;
        }
      }
    }
  }

  Future<Result<void>> _save() async {
    if (_custom) {
      final name = _customName.trim();
      if (name.length < 2)
        return const Err('Add meg a tárgy nevét (legalább 2 karakter).');
      return _repository.addCustomCompletion(
        name: name,
        code: _customCode,
        credits: _customCredits,
        semester: _semester,
        grade: _grade,
      );
    }

    final subject = _subject;
    if (subject == null) return const Err('Válassz tárgyat.');
    return _repository.addCompletion(
        subjectId: subject.id, semester: _semester, grade: _grade);
  }
}
