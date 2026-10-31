import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:itk_app/data/repositories/absolutorium_repository.dart';
import 'package:itk_app/domain/models/averages.dart';

class DiplomaViewModel extends ChangeNotifier {
  DiplomaViewModel({required AbsolutoriumRepository repository}) : _repository = repository {
    _repository.completions.addListener(_onCompletionsChanged);
    _repository.diplomaInputs.addListener(notifyListeners);
    if (_repository.completions.value == null) unawaited(_repository.getCompletions());
  }

  static const grades = <int?>[5, 4, 3, 2, 1, null];

  final AbsolutoriumRepository _repository;

  @override
  void dispose() {
    _repository.completions.removeListener(_onCompletionsChanged);
    _repository.diplomaInputs.removeListener(notifyListeners);
    super.dispose();
  }

  bool _dirty = true;
  AverageSummary _averages = AverageSummary.empty;

  void _onCompletionsChanged() {
    _dirty = true;
    notifyListeners();
  }

  AverageSummary get averages {
    if (_dirty) {
      _dirty = false;
      final source = _repository.completions.value;
      _averages = source == null ? AverageSummary.empty : computeAverages(source);
    }
    return _averages;
  }

  bool get loading => _repository.completions.value == null;

  DiplomaInputs get inputs => _repository.diplomaInputs.value;

  DiplomaEstimate? get estimate => estimateDiploma(averages.diplomaWeightedAverage, inputs);

  List<HonoursCondition> get honours => honoursConditions(averages, inputs);

  bool? get honoursMet {
    final list = honours;
    if (list.any((c) => c.met == false)) return false;
    if (list.every((c) => c.met == true)) return true;
    return null;
  }

  void setThesis(int? grade) => unawaited(_repository.setDiplomaInputs(inputs.withThesis(grade)));

  void setFinalExam(int? grade) => unawaited(_repository.setDiplomaInputs(inputs.withFinalExam(grade)));
}