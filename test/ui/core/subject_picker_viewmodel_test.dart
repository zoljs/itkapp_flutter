import 'package:flutter_test/flutter_test.dart';
import 'package:itk_app/ui/core/screens/viewmodels/subject_multi_picker_viewmodel.dart';
import 'package:itk_app/ui/core/screens/viewmodels/subject_picker_viewmodel.dart';
import 'package:itk_app/utils/result.dart';

import '../../helpers/fake_http.dart';
import '../../helpers/fake_repositories.dart';
import '../../helpers/fixtures.dart';

void main() {
  late FakeSubjectsRepository subjects;

  setUp(() {
    subjects = FakeSubjectsRepository()..getResult = const Ok([analysis, programming]);
  });

  group('SubjectPickerViewModel', () {
    test('betölti a tárgyakat', () async {
      final viewModel = SubjectPickerViewModel(repository: subjects);
      await flush();

      expect(viewModel.subjects, [analysis, programming]);
      viewModel.dispose();
    });

    test('név és kód szerint szűr', () async {
      final viewModel = SubjectPickerViewModel(repository: subjects);
      await flush();

      viewModel.setQuery('prog');
      expect(viewModel.filteredSubjects, [programming]);

      viewModel.setQuery('itk101');
      expect(viewModel.filteredSubjects, [analysis]);

      viewModel.setQuery('');
      expect(viewModel.filteredSubjects, hasLength(2));
      viewModel.dispose();
    });
  });

  group('SubjectMultiPickerViewModel', () {
    test('a kezdő kijelölésből indul, és kapcsolgatható', () async {
      final viewModel = SubjectMultiPickerViewModel(
        repository: subjects,
        initialSubjects: ['Analízis I.'],
      );
      await flush();

      expect(viewModel.selectedSubjects, {'Analízis I.'});

      viewModel.toggleSubject('Programozás alapjai');
      expect(viewModel.selectedSubjects, {'Analízis I.', 'Programozás alapjai'});

      viewModel.toggleSubject('Analízis I.');
      expect(viewModel.selectedSubjects, {'Programozás alapjai'});
      viewModel.dispose();
    });
  });
}
