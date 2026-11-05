import 'package:flutter_test/flutter_test.dart';
import 'package:itk_app/domain/models/site_color.dart';
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
    final viewModel =
        MySiteViewModel(wikiSitesRepository: sites, authRepository: auth);
    await flush();
    return viewModel;
  }

  test('meglévő oldal: betölti a beállításait', () async {
    sites.getResult = const Ok(UserSite(
      name: 'Perpa',
      url: 'https://users.itk.ppke.hu/~perpa4',
      tags: ['Analízis'],
      isPublic: false,
      color: SiteColor.green,
    ));

    final viewModel = await create();

    expect(viewModel.hasExistingSite, isTrue);
    expect(viewModel.tags, ['Analízis']);
    expect(viewModel.isPublic, isFalse);
    expect(viewModel.color, SiteColor.green);
    viewModel.dispose();
  });

  test('a cache-ből indul, még a betöltés vége előtt (hero szín)', () async {
    const site = UserSite(
      name: 'Perpa',
      url: 'https://users.itk.ppke.hu/~perpa4',
      tags: ['Fizika'],
      isPublic: false,
      color: SiteColor.green,
    );
    sites.cachedMySite = const Ok(site);
    sites.getResult = const Ok(site);

    // No flush(): check the state right after the constructor.
    final viewModel =
        MySiteViewModel(wikiSitesRepository: sites, authRepository: auth);

    expect(viewModel.color, SiteColor.green);
    expect(viewModel.tags, ['Fizika']);
    expect(viewModel.isPublic, isFalse);
    expect(viewModel.hasExistingSite, isTrue);

    // Let _load finish before dispose, so it doesn't notify a disposed VM.
    await flush();
    viewModel.dispose();
  });

  test('nincs még oldal: alapértékek', () async {
    final viewModel = await create();

    expect(viewModel.hasExistingSite, isFalse);
    expect(viewModel.tags, isEmpty);
    expect(viewModel.isPublic, isTrue);
    expect(viewModel.color, SiteColor.fallback);
    viewModel.dispose();
  });

  test('mentéskor az aktuális beállításokat küldi', () async {
    final viewModel = await create()
      ..setTags(['Fizika'])
      ..setPublic(false)
      ..setColor(SiteColor.amber);

    await viewModel.save.execute();

    expect(viewModel.save.completed, isTrue);
    expect(sites.lastSave?.tags, ['Fizika']);
    expect(sites.lastSave?.isPublic, isFalse);
    expect(sites.lastSave?.color, SiteColor.amber);
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
