import 'dart:collection';

import 'package:itk_app/ui/core/screens/viewmodels/subject_picker_viewmodel.dart';

class SubjectMultiPickerViewModel extends SubjectPickerViewModel {
  SubjectMultiPickerViewModel({
    required super.repository,
    required List<String> initialSubjects,
  }) : _selectedSubjects = Set.of(initialSubjects);

  final Set<String> _selectedSubjects;
  UnmodifiableSetView<String> get selectedSubjects => UnmodifiableSetView(_selectedSubjects);

  void toggleSubject(String subject) {
    if (_selectedSubjects.contains(subject)) {
      _selectedSubjects.remove(subject);
    } else {
      _selectedSubjects.add(subject);
    }

    notifyListeners();
  }
}
