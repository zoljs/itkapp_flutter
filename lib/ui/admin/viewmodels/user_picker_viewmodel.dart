import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:itk_app/data/services/admin/users_service.dart';
import 'package:itk_app/domain/models/user_summary.dart';
import 'package:itk_app/utils/command.dart';
import 'package:itk_app/utils/result.dart';

class UserPickerViewModel extends ChangeNotifier {
  UserPickerViewModel({required AdminUsersService service})
      : _service = service {
    load = Command0<void>(_load)..execute();
  }

  factory UserPickerViewModel.create() =>
      UserPickerViewModel(service: AdminUsersService.instance);

  final AdminUsersService _service;

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
    return _users
        .where((u) =>
            u.fullName.toLowerCase().contains(q) ||
            u.ldapUsername.toLowerCase().contains(q))
        .toList();
  }

  // Methods
  Future<Result<void>> _load() async {
    final result = await _service.getUsers();

    switch (result) {
      case Ok(:final value):
        _users = value;
        notifyListeners();
        return const Ok(null);
      case Err(:final message):
        return Err(message);
    }
  }

  void setQuery(String value) {
    _query = value;
    notifyListeners();
  }
}
