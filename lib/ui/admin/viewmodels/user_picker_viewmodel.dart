import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:itk_app/data/services/admin/users_service.dart';
import 'package:itk_app/domain/models/user_summary.dart';
import 'package:itk_app/utils/result.dart';

class UserPickerViewModel extends ChangeNotifier {
  UserPickerViewModel({required AdminUsersService service})
      : _service = service;

  factory UserPickerViewModel.create() =>
      UserPickerViewModel(service: AdminUsersService.instance);

  final AdminUsersService _service;

  // State
  List<UserSummary> _users = [];
  bool _loading = true;
  String? _error;
  String _query = '';

  // Getters
  UnmodifiableListView<UserSummary> get users => UnmodifiableListView(_users);
  bool get loading => _loading;
  String? get error => _error;
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
  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListeners();

    final result = await _service.getUsers();

    switch (result) {
      case Ok(:final value):
        _users = value;
      case Err(:final message):
        _error = message;
    }
    _loading = false;
    notifyListeners();
  }

  void setQuery(String value) {
    _query = value;
    notifyListeners();
  }
}
