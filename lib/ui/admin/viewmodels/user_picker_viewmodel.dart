import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:itk_app/data/repositories/admin/admin_users_repository.dart';
import 'package:itk_app/domain/models/user_summary.dart';
import 'package:itk_app/utils/command.dart';
import 'package:itk_app/utils/result.dart';

class UserPickerViewModel extends ChangeNotifier {
  UserPickerViewModel({required AdminUsersRepository repository}) : _repository = repository {
    load = Command0<void>(_load)..execute();
  }

  final AdminUsersRepository _repository;

  @override
  void dispose() {
    load.dispose();
    super.dispose();
  }

  // State
  List<UserSummary> _users = [];
  late final Command0<void> load;
  String _query = '';

  // Getters
  UnmodifiableListView<UserSummary> get users => UnmodifiableListView(_users);
  String get query => _query;

  List<UserSummary> get filteredUsers {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return _users;
    return _users.where((u) => u.fullName.toLowerCase().contains(q) || u.ldapUsername.toLowerCase().contains(q)).toList();
  }

  // Methods
  Future<Result<void>> _load() async {
    final result = await _repository.getUsers();

    if (result case Ok(:final value)) {
      _users = value;
      notifyListeners();
    }
    return result;
  }

  void setQuery(String value) {
    _query = value;
    notifyListeners();
  }
}
