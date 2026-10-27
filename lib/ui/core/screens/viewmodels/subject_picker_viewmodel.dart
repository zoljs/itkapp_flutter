import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:itk_app/data/repositories/subjects_repository.dart';
import 'package:itk_app/domain/models/subject.dart';
import 'package:itk_app/utils/command.dart';
import 'package:itk_app/utils/result.dart';

class SubjectPickerViewModel extends ChangeNotifier {
  SubjectPickerViewModel({required SubjectsRepository repository}) : _repository = repository {
    load = Command0<void>(_load)..execute();
  }

  final SubjectsRepository _repository;

  @override
  void dispose() {
    load.dispose();
    super.dispose();
  }

  // State
  List<Subject> _subjects = [];
  late final Command0<void> load;
  String _query = '';

  // Getters
  UnmodifiableListView<Subject> get subjects => UnmodifiableListView(_subjects);

  String get query => _query;
  void setQuery(String value) {
    _query = value;
    notifyListeners();
  }

  List<Subject> get filteredSubjects {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return subjects;
    return _subjects.where((s) => s.name.toLowerCase().contains(q) || s.code.toLowerCase().contains(q)).toList();
  }

  // Methods
  Future<Result<void>> _load() async {
    final result = await _repository.getSubjects();

    if (result case Ok(:final value)) {
      _subjects = value;
      notifyListeners();
    }
    return result;
  }
}
