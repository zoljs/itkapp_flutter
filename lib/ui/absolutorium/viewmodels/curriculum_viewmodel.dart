import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:itk_app/data/repositories/absolutorium_repository.dart';
import 'package:itk_app/domain/models/absolutorium.dart';
import 'package:itk_app/utils/command.dart';
import 'package:itk_app/utils/result.dart';

class CurriculumViewModel extends ChangeNotifier {
  CurriculumViewModel({
    required AbsolutoriumRepository repository,
    int? initialCurriculumId,
    int? initialSpecializationId,
  })  : _repository = repository,
        _curriculumId = initialCurriculumId,
        _specializationId = initialSpecializationId {
    load = Command0<void>(_load);
    save = Command0<void>(_save);
    unawaited(load.execute());
  }

  final AbsolutoriumRepository _repository;
  late final Command0<void> load;
  late final Command0<void> save;

  @override
  void dispose() {
    load.dispose();
    save.dispose();
    super.dispose();
  }

  List<CurriculumOption> _curricula = [];
  int? _curriculumId;
  int? _specializationId;

  UnmodifiableListView<CurriculumOption> get curricula => UnmodifiableListView(_curricula);

  int? get curriculumId => _curriculumId;

  int? get specializationId => _specializationId;

  CurriculumOption? get selected {
    for (final c in _curricula) {
      if (c.id == _curriculumId) return c;
    }
    return null;
  }

  Map<String, List<CurriculumOption>> get byMajor {
    final map = <String, List<CurriculumOption>>{};
    for (final c in _curricula) {
      map.putIfAbsent(c.major, () => []).add(c);
    }
    return map;
  }

  bool get canSave => _curriculumId != null && !save.running;

  void selectCurriculum(int id) {
    if (id == _curriculumId) return;
    _curriculumId = id;
    _specializationId = null;
    notifyListeners();
  }

  void selectSpecialization(int? id) {
    _specializationId = id;
    notifyListeners();
  }

  Future<Result<void>> _load() async {
    final result = await _repository.getCurricula();
    if (result case Ok(:final value)) {
      _curricula = value;
      if (_curriculumId == null && value.length == 1) _curriculumId = value.first.id;
      notifyListeners();
    }
    return result;
  }

  Future<Result<void>> _save() async {
    final curriculumId = _curriculumId;
    if (curriculumId == null) return const Err('Válassz tantervet.');
    return _repository.setCurriculum(
      curriculumId: curriculumId,
      specializationGroupId: _specializationId,
    );
  }
}
