import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:itk_app/data/repositories/absolutorium_repository.dart';
import 'package:itk_app/domain/models/absolutorium.dart';
import 'package:itk_app/domain/models/averages.dart';
import 'package:itk_app/utils/command.dart';
import 'package:itk_app/utils/result.dart';

class AbsolutoriumViewModel extends ChangeNotifier {
  AbsolutoriumViewModel({required AbsolutoriumRepository repository})
      : _repository = repository {
    load = Command1<void, bool>(_load);
    delete = Command1<void, int>(_delete);
    _repository.progress.addListener(notifyListeners);
    _repository.completions.addListener(notifyListeners);
    _repository.diplomaInputs.addListener(notifyListeners);
    unawaited(load.execute(false));
  }

  final AbsolutoriumRepository _repository;
  late final Command1<void, bool> load;
  late final Command1<void, int> delete;

  @override
  void dispose() {
    _repository.progress.removeListener(notifyListeners);
    _repository.completions.removeListener(notifyListeners);
    _repository.diplomaInputs.removeListener(notifyListeners);
    load.dispose();
    delete.dispose();
    super.dispose();
  }

  final Set<int> _hidden = {};

  AbsolutoriumProgress? get progress => _repository.progress.value;

  bool get initialLoading => load.running && progress == null;

  bool get needsCurriculum =>
      !load.running && load.errorMessage == null && progress == null;

  List<CompletedSubject> get uncategorized =>
      (progress?.uncategorized ?? const <CompletedSubject>[])
          .where((c) => !_hidden.contains(c.completionId))
          .toList();

  List<Completion>? _averagesSource;
  AverageSummary _averages = AverageSummary.empty;

  AverageSummary get averages {
    final source = _repository.completions.value;
    if (!identical(source, _averagesSource)) {
      _averagesSource = source;
      _averages =
          source == null ? AverageSummary.empty : computeAverages(source);
    }
    return _averages;
  }

  DiplomaEstimate? get diploma => estimateDiploma(
      averages.diplomaWeightedAverage, _repository.diplomaInputs.value);

  Future<Result<void>> _load(bool forceReload) async {
    unawaited(_repository.getCompletions(
        forceReload: forceReload, maxAge: const Duration(seconds: 30)));
    final result = await _repository.getProgress(
      forceReload: forceReload,
      maxAge: const Duration(seconds: 30),
    );
    return switch (result) {
      Ok() => const Ok(null),
      Err(:final message) => Err(message),
    };
  }

  Future<Result<void>> _delete(int completionId) async {
    _hidden.add(completionId);
    notifyListeners();

    final result = await _repository.deleteCompletion(completionId);
    if (result is Err) {
      _hidden.remove(completionId);
      notifyListeners();
    }
    return result;
  }
}
