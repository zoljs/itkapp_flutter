import 'package:itk_app/data/repositories/subjects_repository.dart';
import 'package:itk_app/domain/models/subject.dart';
import 'package:itk_app/ui/core/screens/viewmodels/picker_viewmodel.dart';

class SubjectPickerViewModel extends PickerViewModel<Subject> {
  SubjectPickerViewModel({required SubjectsRepository repository})
      : super(
          fetch: repository.get,
          matches: (subject, q) =>
              subject.name.toLowerCase().contains(q) ||
              subject.code.toLowerCase().contains(q),
        );
}
