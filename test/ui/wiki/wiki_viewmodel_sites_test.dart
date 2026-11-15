import 'package:flutter_test/flutter_test.dart';
import 'package:itk_app/domain/models/user_site.dart';
import 'package:itk_app/ui/wiki/viewmodels/wiki_viewmodel.dart';
import 'package:itk_app/utils/result.dart';

import '../../helpers/fake_http.dart';
import '../../helpers/fake_repositories.dart';
import '../../helpers/fixtures.dart';

const _own = UserSite(
  login: 'perpa4',
  name: 'Teszt Elek',
  url: 'https://users.itk.ppke.hu/~perpa4',
  tags: ['Analízis'],
);
const _other = UserSite(
  login: 'kiss1',
  name: 'Kiss Béla',
  url: 'https://users.itk.ppke.hu/~kiss1',
  tags: ['Programozás'],
);
const _third = UserSite(
  login: 'nagy2',
  name: 'Nagy Anna',
  url: 'https://example.com/anna',
  tags: ['Diszkrét matematika'],
);

void main() {
  late FakeSitesRepository sites;
  late FakeAuthRepository auth;
  late WikiViewModel viewModel;

  Future<void> build() async {
    viewModel = WikiViewModel(
      wikiSitesRepository: sites,
      wikiFilesRepository: FakeWikiFilesRepository(),
      authRepository: auth,
    );
    await flush();
  }

  setUp(() {
    sites = FakeSitesRepository();
    auth = FakeAuthRepository()..cachedUser = user();
  });

  tearDown(() => viewModel.dispose());

  group('betöltés', () {
    test('az oldalak és a saját oldal bekerül, a töltés véget ér', () async {
      sites.getAllResult = const Ok([_own, _other]);
      sites.getResult = const Ok(_own);

      await build();

      expect(viewModel.sites, [_own, _other]);
      expect(viewModel.mySite, _own);
      expect(viewModel.sitesInitialLoading, isFalse);
      expect(viewModel.mySiteInitialLoading, isFalse);
      expect(viewModel.load.completed, isTrue);
    });

    test('hiba: a lista üres marad, a hibaüzenet elérhető', () async {
      sites.getAllResult = const Err('Nem érhető el a szerver.');

      await build();

      expect(viewModel.sites, isEmpty);
      expect(viewModel.load.completed, isFalse);
      expect(viewModel.load.errorMessage, 'Nem érhető el a szerver.');
    });

    test('a bejelentkezett user login-ja elérhető', () async {
      await build();

      expect(viewModel.login, 'perpa4');
    });
  });

  group('filteredSites', () {
    test('a saját oldal nem jelenik meg a listában', () async {
      sites.getAllResult = const Ok([_own, _other]);
      sites.getResult = const Ok(_own);

      await build();

      expect(viewModel.filteredSites, [_other]);
    });

    test('ha nincs saját oldal, minden oldal látszik', () async {
      sites.getAllResult = const Ok([_own, _other]);
      sites.getResult = const Ok(null);

      await build();

      expect(viewModel.filteredSites, [_own, _other]);
    });

    test('keresés névre, kis- és nagybetűtől függetlenül', () async {
      sites.getAllResult = const Ok([_other, _third]);
      await build();

      viewModel.setQuery('kISS');

      expect(viewModel.filteredSites, [_other]);
    });

    test('keresés címkére', () async {
      sites.getAllResult = const Ok([_other, _third]);
      await build();

      viewModel.setQuery('diszkrét');

      expect(viewModel.filteredSites, [_third]);
    });

    test('keresés URL-re', () async {
      sites.getAllResult = const Ok([_other, _third]);
      await build();

      viewModel.setQuery('example.com');

      expect(viewModel.filteredSites, [_third]);
    });

    test('a keresőszó szélső szóközei nem számítanak', () async {
      sites.getAllResult = const Ok([_other, _third]);
      await build();

      viewModel.setQuery('  anna ');

      expect(viewModel.filteredSites, [_third]);
      expect(viewModel.query, '  anna ');
    });

    test('keresés közben is rejtve marad a saját oldal', () async {
      sites.getAllResult = const Ok([_own, _other]);
      sites.getResult = const Ok(_own);
      await build();

      viewModel.setQuery('teszt');

      expect(viewModel.filteredSites, isEmpty);
    });

    test('setQuery értesíti a figyelőket', () async {
      await build();
      var notified = 0;
      viewModel.addListener(() => notified++);

      viewModel.setQuery('x');

      expect(notified, 1);
    });
  });
}
