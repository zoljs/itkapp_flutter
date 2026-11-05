import 'package:flutter_test/flutter_test.dart';
import 'package:itk_app/ui/admin/viewmodels/admin_roles_viewmodel.dart';
import 'package:itk_app/utils/result.dart';

import '../../helpers/fake_http.dart';
import '../../helpers/fake_repositories.dart';
import '../../helpers/fixtures.dart';

void main() {
  late FakeAdminRolesRepository repository;

  setUp(() {
    repository = FakeAdminRolesRepository()
      ..getResult = Ok([
        summary(1, 'Teszt Elek', 'tesel1'),
        summary(2, 'Minta Anna', 'minan2')
      ]);
  });

  Future<AdminRolesViewModel> create() async {
    final viewModel = AdminRolesViewModel(repository: repository);
    await flush();
    return viewModel;
  }

  test('betölti az évfolyamfelelősöket', () async {
    final viewModel = await create();
    expect(viewModel.roleHolders.map((u) => u.userId), [1, 2]);
    viewModel.dispose();
  });

  test('kinevezés után újratölt', () async {
    final viewModel = await create();
    final before = repository.getCount;

    await viewModel.assign.execute(3);

    expect(repository.getCount, before + 1);
    viewModel.dispose();
  });

  test('visszavonás: azonnal kiveszi', () async {
    final viewModel = await create();

    await viewModel.revoke.execute(1);

    expect(viewModel.roleHolders.map((u) => u.userId), [2]);
    viewModel.dispose();
  });

  test('visszavonás hibája: újratölt, a user visszakerül', () async {
    final viewModel = await create();
    repository.revokeResult = const Err('Nincs jogosultság.');

    await viewModel.revoke.execute(1);

    expect(viewModel.revoke.errorMessage, 'Nincs jogosultság.');
    expect(viewModel.roleHolders.map((u) => u.userId), [1, 2]);
    viewModel.dispose();
  });
}
