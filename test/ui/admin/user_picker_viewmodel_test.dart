import 'package:flutter_test/flutter_test.dart';
import 'package:itk_app/ui/admin/viewmodels/user_picker_viewmodel.dart';
import 'package:itk_app/utils/result.dart';

import '../../helpers/fake_http.dart';
import '../../helpers/fake_repositories.dart';
import '../../helpers/fixtures.dart';

void main() {
  test('név és felhasználónév szerint szűr', () async {
    final repository = FakeAdminUsersRepository()
      ..getResult = Ok([
        summary(1, 'Teszt Elek', 'tesel1'),
        summary(2, 'Minta Anna', 'minan2')
      ]);
    final viewModel = UserPickerViewModel(repository: repository);
    await flush();

    viewModel.setQuery('anna');
    expect(viewModel.filteredUsers.map((u) => u.userId), [2]);

    viewModel.setQuery('TESEL');
    expect(viewModel.filteredUsers.map((u) => u.userId), [1]);

    viewModel.setQuery('');
    expect(viewModel.filteredUsers, hasLength(2));
    viewModel.dispose();
  });
}
