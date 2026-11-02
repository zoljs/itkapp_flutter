import 'package:flutter_test/flutter_test.dart';
import 'package:itk_app/domain/models/user_site.dart';
import 'package:itk_app/ui/wiki/viewmodels/my_site_viewmodel.dart';
import 'package:itk_app/utils/result.dart';

import '../../helpers/fake_http.dart';
import '../../helpers/fake_repositories.dart';
import '../../helpers/fixtures.dart';

void main() {
  late FakeSitesRepository sites;
  late FakeAuthRepository auth;

  setUp(() {
    sites = FakeSitesRepository();
    auth = FakeAuthRepository()..cachedUser = user();
  });

  Future<MySiteViewModel> create() async {
    final viewModel = MySiteViewModel(wikiSitesRepository: sites, authRepository: auth);
    await flush();
    return viewModel;
  }

  test('meglévő oldal: betölti a beállításait', () async {
    sites.getResult = const Ok(UserSite(
      name: 'Perpa',
      url: 'https://users.itk.ppke.hu/~perpa4',
      tags: ['Analízis'],
      isPublic: false,
    ));

    final viewModel = await create();

    expect(viewModel.hasExistingSite, isTrue);
    expect(viewModel.tags, ['Analízis']);
    expect(viewModel.isPublic, isFalse);
    viewModel.dispose();
  });

  test('nincs még oldal: alapértékek', () async {
    final viewModel = await create();

    expect(viewModel.hasExistingSite, isFalse);
    expect(viewModel.tags, isEmpty);
    expect(viewModel.isPublic, isTrue);
    viewModel.dispose();
  });

  test('mentéskor az aktuális beállításokat küldi', () async {
    final viewModel = await create()
      ..setTags(['Fizika'])
      ..setPublic(false);

    await viewModel.save.execute();

    expect(viewModel.save.completed, isTrue);
    expect(sites.lastSave?.tags, ['Fizika']);
    expect(sites.lastSave?.isPublic, isFalse);
    viewModel.dispose();
  });

  test('bejelentkezés nélkül nem ment', () async {
    auth.cachedUser = null;
    final viewModel = await create();

    await viewModel.save.execute();

    expect(viewModel.save.errorMessage, isNotNull);
    expect(sites.lastSave, isNull);
    viewModel.dispose();
  });
}
