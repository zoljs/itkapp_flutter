// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:itk_app/data/repositories/auth_repository.dart';
import 'package:itk_app/data/repositories/subjects_repository.dart';
import 'package:itk_app/data/repositories/wiki_sites_repository.dart';
import 'package:itk_app/domain/models/site_color.dart';
import 'package:itk_app/domain/models/user_site.dart';
import 'package:itk_app/routing/routes.dart';
import 'package:itk_app/ui/core/widgets/grouped_list.dart';
import 'package:itk_app/ui/wiki/my_site_screen.dart';
import 'package:itk_app/ui/wiki/widgets/my_site_color_picker.dart';
import 'package:itk_app/utils/result.dart';
import 'package:provider/provider.dart';

import '../../helpers/fake_repositories.dart';
import '../../helpers/fixtures.dart';

const _site = UserSite(
  login: 'perpa4',
  name: 'Teszt Elek',
  url: 'https://users.itk.ppke.hu/~perpa4',
  tags: ['Analízis', 'Programozás'],
  isPublic: true,
  color: SiteColor.green,
);

void main() {
  late FakeSitesRepository sites;
  late FakeAuthRepository auth;
  late FakeSubjectsRepository subjects;

  setUp(() {
    sites = FakeSitesRepository();
    auth = FakeAuthRepository()..cachedUser = user();
    subjects = FakeSubjectsRepository()
      ..getResult = const Ok([analysis, programming]);
  });

  /// The screen is opened from a host page, so that a `Navigator.pop` has
  /// somewhere to go back to.
  Future<void> pump(WidgetTester tester) async {
    // Tall viewport: the whole form is on screen, no scrolling needed.
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(800, 2400);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, _) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => context.push(Routes.wikiEdit),
                child: const Text('Megnyit'),
              ),
            ),
          ),
        ),
        GoRoute(path: Routes.wikiEdit, builder: (_, __) => const MySiteScreen()),
        GoRoute(
          path: Routes.wikiSetup,
          builder: (_, __) =>
              Scaffold(body: Center(child: Text('oldal: ${Routes.wikiSetup}'))),
        ),
      ],
    );
    await tester.pumpWidget(MultiProvider(
      providers: [
        Provider<WikiSitesRepository>.value(value: sites),
        ChangeNotifierProvider<AuthRepository>.value(value: auth),
        Provider<SubjectsRepository>.value(value: subjects),
      ],
      child: MaterialApp.router(routerConfig: router),
    ));
    await tester.tap(find.text('Megnyit'));
    await tester.pumpAndSettle();
  }

  Future<void> tapSave(WidgetTester tester) async {
    await tester.tap(find.byIcon(Icons.check_rounded));
    await tester.pumpAndSettle();
  }

  group('új oldal', () {
    testWidgets('létrehozás cím, nincs törlés gomb, alapértékek',
        (tester) async {
      await pump(tester);

      expect(find.text('Oldal létrehozása'), findsOneWidget);
      expect(find.text('perpa4'), findsOneWidget);
      expect(find.text('Oldal törlése'), findsNothing);
      expect(find.byType(Switch), findsOneWidget);
      expect(tester.widget<Switch>(find.byType(Switch)).value, isTrue);
    });

    testWidgets('mentés az alapértékekkel: nyilvános, nincs címke',
        (tester) async {
      await pump(tester);

      await tapSave(tester);

      expect(sites.lastSave, isNotNull);
      expect(sites.lastSave?.tags, isEmpty);
      expect(sites.lastSave?.isPublic, isTrue);
      expect(sites.lastSave?.color, SiteColor.fallback);
      expect(find.text('Megnyit'), findsOneWidget);
    });
  });

  group('meglévő oldal', () {
    setUp(() => sites.getResult = const Ok(_site));

    testWidgets('a mentett beállítások betöltődnek', (tester) async {
      await pump(tester);

      expect(find.text('Saját oldalam'), findsOneWidget);
      expect(find.text('Analízis'), findsOneWidget);
      expect(find.text('Programozás'), findsOneWidget);
      expect(find.text('Oldal törlése'), findsOneWidget);
    });

    testWidgets('a publikus kapcsoló átváltása elmegy a mentéssel',
        (tester) async {
      await pump(tester);

      await tester.tap(find.text('Oldal publikussá tétele'));
      await tester.pump();
      await tapSave(tester);

      expect(sites.lastSave?.isPublic, isFalse);
      expect(sites.lastSave?.tags, ['Analízis', 'Programozás']);
    });

    testWidgets('a szín választása elmegy a mentéssel', (tester) async {
      await pump(tester);

      final swatches = find.descendant(
        of: find.byType(MySiteColorPicker),
        matching: find.byType(AnimatedContainer),
      );
      await tester.tap(swatches.at(2 * SiteColor.purple.index));
      await tester.pumpAndSettle();
      await tapSave(tester);

      expect(sites.lastSave?.color, SiteColor.purple);
    });

    testWidgets('címke törlése megerősítéssel kikerül a mentésből',
        (tester) async {
      await pump(tester);

      await tester.drag(find.text('Programozás'), const Offset(-600, 0));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Törlés'));
      await tester.pumpAndSettle();
      await tapSave(tester);

      expect(sites.lastSave?.tags, ['Analízis']);
    });

    testWidgets('a címkeválasztó hozzáadja a kiválasztott tárgyat',
        (tester) async {
      await pump(tester);

      await tester.tap(find.widgetWithText(SettingsTile, 'Új címke hozzáadása'));
      await tester.pumpAndSettle();
      expect(find.text('Címkék'), findsWidgets);

      await tester.tap(find.text('Analízis I.'));
      await tester.pump();
      await tester.tap(find.byIcon(Icons.check_rounded).last);
      await tester.pumpAndSettle();
      await tapSave(tester);

      expect(sites.lastSave?.tags,
          unorderedEquals(['Analízis', 'Programozás', 'Analízis I.']));
    });
  });

  group('mentés eredménye', () {
    testWidgets('siker: Elmentve! üzenet és visszalépés', (tester) async {
      await pump(tester);

      await tapSave(tester);

      expect(find.text('Elmentve!'), findsOneWidget);
      expect(find.text('Megnyit'), findsOneWidget);
    });

    testWidgets('szerverhiba: üzenet, a képernyő marad', (tester) async {
      sites.saveError = const Err('Nem sikerült menteni.');
      await pump(tester);

      await tapSave(tester);

      expect(find.text('Nem sikerült menteni.'), findsOneWidget);
      expect(find.text('Oldal létrehozása'), findsOneWidget);
    });

    testWidgets('bejelentkezés nélkül nem ment, üzenetet ad', (tester) async {
      auth.cachedUser = null;
      await pump(tester);

      await tapSave(tester);

      expect(sites.lastSave, isNull);
      expect(find.text('Nincs bejelentkezett felhasználó.'), findsOneWidget);
    });
  });

  group('oldal törlése', () {
    setUp(() => sites.getResult = const Ok(_site));

    testWidgets('megerősítés után töröl, üzenet és visszalépés',
        (tester) async {
      await pump(tester);

      await tester.tap(find.text('Oldal törlése'));
      await tester.pumpAndSettle();
      expect(find.text('Profil törlése'), findsOneWidget);
      expect(sites.deleteCount, 0);

      await tester.tap(find.widgetWithText(FilledButton, 'Törlés'));
      await tester.pumpAndSettle();

      expect(sites.deleteCount, 1);
      expect(find.text('Saját oldalad törölve lett.'), findsOneWidget);
      expect(find.text('Megnyit'), findsOneWidget);
    });

    testWidgets('mégse: nem töröl', (tester) async {
      await pump(tester);

      await tester.tap(find.text('Oldal törlése'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Mégse'));
      await tester.pumpAndSettle();

      expect(sites.deleteCount, 0);
      expect(find.text('Saját oldalam'), findsOneWidget);
    });

    testWidgets('szerverhiba: üzenet, a képernyő marad', (tester) async {
      sites.deleteResult = const Err('Nem sikerült törölni.');
      await pump(tester);

      await tester.tap(find.text('Oldal törlése'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Törlés'));
      await tester.pumpAndSettle();

      expect(find.text('Nem sikerült törölni.'), findsOneWidget);
      expect(find.text('Saját oldalam'), findsOneWidget);
    });
  });

  testWidgets('a fájlkezelő sora a beállító oldalra visz', (tester) async {
    await pump(tester);

    await tester.tap(find.text('Fájlkezelő beállítása'));
    await tester.pumpAndSettle();

    expect(find.text('oldal: ${Routes.wikiSetup}'), findsOneWidget);
  });
}
