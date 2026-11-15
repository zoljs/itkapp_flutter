import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:itk_app/data/repositories/auth_repository.dart';
import 'package:itk_app/data/repositories/wiki_files_repository.dart';
import 'package:itk_app/data/repositories/wiki_sites_repository.dart';
import 'package:itk_app/domain/models/user_site.dart';
import 'package:itk_app/domain/models/wiki_file.dart';
import 'package:itk_app/routing/routes.dart';
import 'package:itk_app/ui/core/widgets/settings_avatar_button.dart';
import 'package:itk_app/ui/wiki/widgets/site_list_card.dart';
import 'package:itk_app/ui/wiki/wiki_screen.dart';
import 'package:itk_app/utils/result.dart';
import 'package:provider/provider.dart';

import '../../helpers/fake_repositories.dart';
import '../../helpers/fixtures.dart';

const _own = UserSite(
  login: 'perpa4',
  name: 'Teszt Elek',
  url: 'https://users.itk.ppke.hu/~perpa4',
  tags: ['Analízis'],
  claimed: true,
);
const _kiss = UserSite(
  login: 'kiss1',
  name: 'Kiss Béla',
  url: 'https://users.itk.ppke.hu/~kiss1',
  tags: ['Programozás'],
  claimed: true,
);
const _nagy = UserSite(
  login: 'nagy2',
  name: 'Nagy Anna',
  url: 'https://users.itk.ppke.hu/~nagy2',
  tags: ['Diszkrét matematika'],
  claimed: true,
);

GoRoute _stub(String path) => GoRoute(
      path: path,
      builder: (_, __) => Scaffold(body: Center(child: Text('oldal: $path'))),
    );

void main() {
  late FakeSitesRepository sites;
  late FakeWikiFilesRepository files;
  late FakeAuthRepository auth;

  setUp(() {
    sites = FakeSitesRepository();
    files = FakeWikiFilesRepository();
    auth = FakeAuthRepository()..cachedUser = user();
  });

  Future<void> pump(WidgetTester tester) async {
    final router = GoRouter(
      initialLocation: Routes.wiki,
      routes: [
        GoRoute(path: Routes.wiki, builder: (_, __) => const WikiScreen()),
        _stub(Routes.wikiEdit),
        _stub(Routes.settings),
        GoRoute(
          path: '${Routes.wikiFiles}/:user',
          builder: (_, state) => Scaffold(
              body: Center(child: Text('fájlok: ${state.pathParameters['user']}'))),
        ),
      ],
    );
    await tester.pumpWidget(MultiProvider(
      providers: [
        Provider<WikiSitesRepository>.value(value: sites),
        Provider<WikiFilesRepository>.value(value: files),
        ChangeNotifierProvider<AuthRepository>.value(value: auth),
      ],
      child: MaterialApp.router(routerConfig: router),
    ));
    await tester.pumpAndSettle();
  }

  group('lista', () {
    testWidgets('az oldalak nevei látszanak, a figyelmeztetés is',
        (tester) async {
      sites.getAllResult = const Ok([_kiss, _nagy]);

      await pump(tester);

      expect(find.text('Users Wiki'), findsOneWidget);
      expect(find.byType(SiteListCard), findsNWidgets(2));
      expect(find.text('Kiss Béla'), findsOneWidget);
      expect(find.text('Nagy Anna'), findsOneWidget);
      expect(find.textContaining('A wiki oldalait a szak hallgatói'),
          findsOneWidget);
    });

    testWidgets('üres lista: üres állapot', (tester) async {
      await pump(tester);

      expect(find.text('Még nincs oldal.'), findsOneWidget);
      expect(find.byType(SiteListCard), findsNothing);
    });

    testWidgets('betöltési hiba: üzenet és Újra gomb, ami újratölt',
        (tester) async {
      sites.getAllResult = const Err('Nem érhető el a szerver.');
      await pump(tester);

      expect(find.text('Nem érhető el a szerver.'), findsOneWidget);

      sites.getAllResult = const Ok([_kiss]);
      await tester.tap(find.text('Újra'));
      await tester.pumpAndSettle();

      expect(find.text('Nem érhető el a szerver.'), findsNothing);
      expect(find.text('Kiss Béla'), findsOneWidget);
    });

    testWidgets('a keresés névre és címkére szűr, találat nélkül üzenet',
        (tester) async {
      sites.getAllResult = const Ok([_kiss, _nagy]);
      await pump(tester);

      await tester.enterText(find.byType(TextField), 'anna');
      await tester.pumpAndSettle();
      expect(find.text('Kiss Béla'), findsNothing);
      expect(find.text('Nagy Anna'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'programozás');
      await tester.pumpAndSettle();
      expect(find.text('Kiss Béla'), findsOneWidget);
      expect(find.text('Nagy Anna'), findsNothing);

      await tester.enterText(find.byType(TextField), 'xyz');
      await tester.pumpAndSettle();
      expect(find.textContaining('Nincs találat erre'), findsOneWidget);
    });

    testWidgets('a saját oldal nem szerepel a listában', (tester) async {
      sites.getAllResult = const Ok([_own, _kiss]);
      sites.getResult = const Ok(_own);

      await pump(tester);

      expect(find.byType(SiteListCard), findsOneWidget);
      expect(find.text('Kiss Béla'), findsOneWidget);
    });
  });

  group('saját oldal kártya', () {
    testWidgets('nincs oldal: felhívás, koppintásra a szerkesztőre visz',
        (tester) async {
      await pump(tester);

      expect(find.text('Még nincs saját wiki-oldalad, hozz létre egyet!'),
          findsOneWidget);

      await tester.tap(
          find.text('Még nincs saját wiki-oldalad, hozz létre egyet!'));
      await tester.pumpAndSettle();

      expect(find.text('oldal: ${Routes.wikiEdit}'), findsOneWidget);
    });

    testWidgets('van oldal: a szerkesztés gomb a szerkesztőre visz',
        (tester) async {
      sites.getResult = const Ok(_own);
      await pump(tester);

      expect(find.text('Saját oldalam'), findsOneWidget);

      await tester.tap(find.byTooltip('Szerkesztés'));
      await tester.pumpAndSettle();

      expect(find.text('oldal: ${Routes.wikiEdit}'), findsOneWidget);
    });

    testWidgets('a saját oldalra koppintva ellenőrzi a fájlkezelőt és megnyitja',
        (tester) async {
      sites.getResult = const Ok(_own);
      files.listResult = Ok([WikiFile(name: 'zh1.pdf', isDir: false)]);
      await pump(tester);

      await tester.tap(find.text('Saját oldalam'));
      await tester.pumpAndSettle();

      expect(files.calls, [('', 'perpa4')]);
      expect(find.text('fájlok: perpa4'), findsOneWidget);
    });
  });

  group('oldal megnyitása', () {
    testWidgets('működő fájlkezelőnél a fájlok oldalra visz', (tester) async {
      sites.getAllResult = const Ok([_kiss]);
      files.listResult = Ok([WikiFile(name: 'zh1.pdf', isDir: false)]);
      await pump(tester);

      await tester.tap(find.text('Kiss Béla'));
      await tester.pumpAndSettle();

      expect(files.calls, [('', 'kiss1')]);
      expect(find.text('fájlok: kiss1'), findsOneWidget);
    });
  });

  testWidgets('az avatar a beállításokra visz', (tester) async {
    await pump(tester);

    await tester.tap(find.byType(SettingsAvatarButton));
    await tester.pumpAndSettle();

    expect(find.text('oldal: ${Routes.settings}'), findsOneWidget);
  });
}
