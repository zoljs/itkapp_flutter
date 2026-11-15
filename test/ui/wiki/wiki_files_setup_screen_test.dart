import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:itk_app/data/repositories/auth_repository.dart';
import 'package:itk_app/data/repositories/wiki_files_repository.dart';
import 'package:itk_app/domain/models/wiki_file.dart';
import 'package:itk_app/ui/wiki/viewmodels/wiki_files_setup_viewmodel.dart';
import 'package:itk_app/ui/wiki/wiki_files_setup_screen.dart';
import 'package:itk_app/utils/result.dart';
import 'package:provider/provider.dart';

import '../../helpers/fake_repositories.dart';
import '../../helpers/fixtures.dart';

void main() {
  late FakeWikiFilesRepository files;
  late FakeAuthRepository auth;

  setUp(() {
    files = FakeWikiFilesRepository();
    auth = FakeAuthRepository()..cachedUser = user();
  });

  Future<void> pump(WidgetTester tester) async {
    // Tall viewport: the whole page is on screen, no scrolling needed.
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(800, 2400);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(MultiProvider(
      providers: [
        Provider<WikiFilesRepository>.value(value: files),
        ChangeNotifierProvider<AuthRepository>.value(value: auth),
      ],
      child: const MaterialApp(home: WikiFilesSetupScreen()),
    ));
    await tester.pumpAndSettle();
  }

  testWidgets('a három lépés és a parancsok látszanak', (tester) async {
    await pump(tester);

    expect(find.text('Fájlkezelő beállítása'), findsOneWidget);
    expect(find.text('1. Belépés'), findsOneWidget);
    expect(find.text('2. Telepítés'), findsOneWidget);
    expect(find.text('3. Fájlok'), findsOneWidget);
    expect(find.text('ssh perpa4@users.itk.ppke.hu'), findsOneWidget);
    expect(find.text(WikiFilesSetupViewModel.installCommand), findsOneWidget);
    expect(find.text('~/public_html/files'), findsOneWidget);
  });

  testWidgets('bejelentkezés nélkül az ssh parancsban helyőrző van',
      (tester) async {
    auth.cachedUser = null;

    await pump(tester);

    expect(find.text('ssh <shibboleth>@users.itk.ppke.hu'), findsOneWidget);
  });

  testWidgets('a másolás gomb a vágólapra teszi a parancsot', (tester) async {
    final calls = <MethodCall>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        calls.add(call);
        return null;
      },
    );
    addTearDown(() => tester.binding.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null));
    await pump(tester);

    await tester.tap(find.byIcon(Icons.copy_rounded).first);
    await tester.pumpAndSettle();

    final copy = calls.where((c) => c.method == 'Clipboard.setData').single;
    expect(copy.arguments,
        containsPair('text', 'ssh perpa4@users.itk.ppke.hu'));
    expect(find.text('Másolva.'), findsOneWidget);
  });

  group('ellenőrzés', () {
    Future<void> check(WidgetTester tester) async {
      await tester.tap(find.text('Ellenőrzés'));
      await tester.pumpAndSettle();
    }

    testWidgets('induláskor nincs eredmény doboz', (tester) async {
      await pump(tester);

      expect(find.byIcon(Icons.check_circle_rounded), findsNothing);
      expect(find.byIcon(Icons.error_outline_rounded), findsNothing);
    });

    testWidgets('üres files mappa: sikeres, üres üzenettel', (tester) async {
      await pump(tester);

      await check(tester);

      expect(files.calls, [('', 'perpa4')]);
      expect(find.text('Működik! A files mappa még üres.'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
    });

    testWidgets('fájlokkal: a darabszámot mutatja', (tester) async {
      files.listResult = Ok([
        WikiFile(name: 'zh1.pdf', isDir: false),
        WikiFile(name: 'jegyzet', isDir: true),
      ]);
      await pump(tester);

      await check(tester);

      expect(find.text('Működik! 2 elem van a files mappában.'),
          findsOneWidget);
    });

    testWidgets('hiba: a hibaüzenet látszik', (tester) async {
      files.listResult = const Err('Nem található a files_wiki.php.');
      await pump(tester);

      await check(tester);

      expect(find.text('Nem található a files_wiki.php.'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline_rounded), findsOneWidget);
    });

    testWidgets('bejelentkezés nélkül nem hív szervert, újra bejelentkezést kér',
        (tester) async {
      auth.cachedUser = null;
      await pump(tester);

      await check(tester);

      expect(files.calls, isEmpty);
      expect(find.text('Jelentkezz be újra.'), findsOneWidget);
    });
  });
}
