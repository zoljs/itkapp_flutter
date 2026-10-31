import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:itk_app/data/repositories/absolutorium_repository.dart';
import 'package:itk_app/domain/models/absolutorium.dart';
import 'package:itk_app/domain/models/averages.dart';
import 'package:itk_app/utils/command.dart';
import 'package:itk_app/utils/result.dart';

class CompletionsViewModel extends ChangeNotifier {
  CompletionsViewModel({required AbsolutoriumRepository repository})
      : _repository = repository {
    load = Command1<void, bool>(_load);
    delete = Command1<void, int>(_delete);
    _repository.completions.addListener(_onSourceChanged);
    unawaited(load.execute(false));
  }

  final AbsolutoriumRepository _repository;
  late final Command1<void, bool> load;
  late final Command1<void, int> delete;

  @override
  void dispose() {
    _repository.completions.removeListener(_onSourceChanged);
    load.dispose();
    delete.dispose();
    super.dispose();
  }

  final Set<int> _hidden = {};

  bool _dirty = true;
  List<Completion> _items = const [];
  AverageSummary _averages = AverageSummary.empty;
  Map<String, List<Completion>> _bySemester = const {};

  void _onSourceChanged() {
    _dirty = true;
    notifyListeners();
  }

  void _recompute() {
    if (!_dirty) return;
    _dirty = false;
    final source = _repository.completions.value;
    _items = (source ?? const <Completion>[])
        .where((c) => !_hidden.contains(c.id))
        .toList(growable: false);
    _averages = computeAverages(_items);
    final map = <String, List<Completion>>{};
    for (final c in _items) {
      map.putIfAbsent(c.semester, () => []).add(c);
    }
    _bySemester = map;
  }

  List<Completion> get items {
    _recompute();
    return _items;
  }

  Map<String, List<Completion>> get bySemester {
    _recompute();
    return _bySemester;
  }

  AverageSummary get averages {
    _recompute();
    return _averages;
  }

  bool get initialLoading =>
      load.running && _repository.completions.value == null;

  Future<Result<void>> _load(bool forceReload) async {
    final result = await _repository.getCompletions(
        forceReload: forceReload, maxAge: const Duration(seconds: 30));
    return switch (result) {
      Ok() => const Ok(null),
      Err(:final message) => Err(message),
    };
  }

  Future<Result<void>> _delete(int id) async {
    _hidden.add(id);
    _onSourceChanged();

    final result = await _repository.deleteCompletion(id);
    _hidden.remove(id);
    _onSourceChanged();
    return result;
  }
}
