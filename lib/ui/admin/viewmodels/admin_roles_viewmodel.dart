import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:itk_app/data/repositories/admin/admin_roles_repository.dart';
import 'package:itk_app/domain/models/user_summary.dart';
import 'package:itk_app/utils/command.dart';
import 'package:itk_app/utils/result.dart';

class AdminRolesViewModel extends ChangeNotifier {
  AdminRolesViewModel({required AdminRolesRepository repository})
      : _repository = repository {
    load = Command0<void>(_load)..execute();
    assign = Command1<void, int>(_assign);
    revoke = Command1<void, int>(_revoke);
  }

  final AdminRolesRepository _repository;

  @override
  void dispose() {
    load.dispose();
    assign.dispose();
    revoke.dispose();
    super.dispose();
  }

  // State
  List<UserSummary> _roleHolders = [];
  late final Command0<void> load;
  late final Command1<void, int> assign;
  late final Command1<void, int> revoke;

  // Getters
  UnmodifiableListView<UserSummary> get roleHolders =>
      UnmodifiableListView(_roleHolders);

  bool get initialLoading => load.running && _roleHolders.isEmpty;

  // Methods
  Future<Result<void>> _load() async {
    final result = await _repository.getRoleHolders();

    if (result case Ok(:final value)) {
      _roleHolders = value;
      notifyListeners();
    }
    return result;
  }

  Future<Result<void>> _assign(int id) async {
    final result = await _repository.assignCohortRep(id);
    if (result is Ok) await _load();
    return result;
  }

  Future<Result<void>> _revoke(int id) async {
    _roleHolders = _roleHolders.where((u) => u.userId != id).toList();
    notifyListeners();
    final result = await _repository.revokeRole(id);
    if (result is Err) await _load();
    return result;
  }
}
