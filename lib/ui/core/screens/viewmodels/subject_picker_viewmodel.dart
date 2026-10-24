import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:itk_app/data/services/subjects_service.dart';
import 'package:itk_app/domain/models/subject.dart';
import 'package:itk_app/utils/result.dart';

class SubjectPickerViewModel extends ChangeNotifier {
  SubjectPickerViewModel({required SubjectsService service})
      : _service = service;

  factory SubjectPickerViewModel.create() =>
      SubjectPickerViewModel(service: SubjectsService.instance);

  final SubjectsService _service;

  // State
  List<Subject> _subjects = [];
  bool _loading = true;
  String? _error;
  String _query = '';

  // Getters
  UnmodifiableListView<Subject> get subjects => UnmodifiableListView(_subjects);
  bool get loading => _loading;
  String? get error => _error;
  String get query => _query;

  List<Subject> get filteredSubjects {
    final q = _query.trim().toLowerCase();

    if (q.isEmpty) return subjects;
    return _subjects
        .where((s) =>
            s.name.toLowerCase().contains(q) ||
            s.code.toLowerCase().contains(q))
        .toList();
  }

  // Methods
  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListeners();

    final result = await _service.getSubjects();

    switch (result) {
      case Ok(:final value):
        _subjects = value;
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
