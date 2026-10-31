import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:itk_app/data/repositories/absolutorium_repository.dart';
import 'package:itk_app/domain/models/absolutorium.dart';
import 'package:itk_app/utils/command.dart';
import 'package:itk_app/utils/result.dart';

class GroupDetailViewModel extends ChangeNotifier {
  GroupDetailViewModel(
      {required AbsolutoriumRepository repository, required this.groupId})
      : _repository = repository {
    refresh = Command0<void>(_refresh);
    delete = Command1<void, int>(_delete);
    _repository.progress.addListener(notifyListeners);
    if (_repository.progress.value == null) unawaited(refresh.execute());
  }

  final AbsolutoriumRepository _repository;
  final int groupId;
  late final Command0<void> refresh;
  late final Command1<void, int> delete;

  @override
  void dispose() {
    _repository.progress.removeListener(notifyListeners);
    refresh.dispose();
    delete.dispose();
    super.dispose();
  }

  final Set<int> _hidden = {};

  GroupProgress? get group => _repository.progress.value?.groupById(groupId);

  bool get hasCompleted =>
      group?.subgroups.any((s) => s.completed.isNotEmpty) ?? false;

  List<CompletedSubject> visibleCompleted(SubgroupProgress subgroup) =>
      subgroup.completed
          .where((c) => !_hidden.contains(c.completionId))
          .toList();

  Future<Result<void>> _refresh() async {
    final result = await _repository.getProgress(forceReload: true);
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
