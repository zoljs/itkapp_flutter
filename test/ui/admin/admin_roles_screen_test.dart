import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:itk_app/data/repositories/admin/admin_roles_repository.dart';
import 'package:itk_app/data/repositories/theme_repository.dart';
import 'package:itk_app/ui/admin/admin_roles_screen.dart';
import 'package:itk_app/utils/result.dart';
import 'package:provider/provider.dart';

import '../../helpers/fake_repositories.dart';
import '../../helpers/fixtures.dart';
import '../../helpers/prefs.dart';

Future<void> _pump(
  WidgetTester tester,
  FakeAdminRolesRepository roles, {
  bool asFab = false,
}) async {
  final theme = await makeThemeRepository(actionButtonAsFab: asFab);
  await tester.pumpWidget(MultiProvider(
    providers: [
      Provider<AdminRolesRepository>.value(value: roles),
      Provider<ThemeRepository>.value(value: theme),
    ],
    child: const MaterialApp(home: AdminRolesScreen()),
  ));
  await tester.pumpAndSettle();
}

void main() {
  late FakeAdminRolesRepository roles;

  setUp(() => roles = FakeAdminRolesRepository());

  testWidgets('a kinevezettek neve és loginja látszik', (tester) async {
    roles.getResult = Ok([
      summary(1, 'Teszt Elek', 'perpa4'),
      summary(2, 'Kiss Béla', 'kiss1'),
    ]);

    await _pump(tester, roles);

    expect(find.text('Jogosultságok'), findsOneWidget);
    expect(find.text('Évfolyamfelelősök'), findsOneWidget);
    expect(find.text('Teszt Elek'), findsOneWidget);
    expect(find.text('perpa4'), findsOneWidget);
    expect(find.text('Kiss Béla'), findsOneWidget);
  });

  testWidgets('nincs kinevezett: üres állapot', (tester) async {
    await _pump(tester, roles);

    expect(find.text('Még nincs évfolyamfelelős.'), findsOneWidget);
  });

  testWidgets('hiba esetén üzenet és Újra gomb, ami újratölt', (tester) async {
    roles.getResult = const Err('Nem érhető el a szerver.');
    await _pump(tester, roles);

    expect(find.text('Nem érhető el a szerver.'), findsOneWidget);
    expect(roles.getCount, 1);

    roles.getResult = Ok([summary(1, 'Teszt Elek', 'perpa4')]);
    await tester.tap(find.text('Újra'));
    await tester.pumpAndSettle();

    expect(roles.getCount, 2);
    expect(find.text('Teszt Elek'), findsOneWidget);
    expect(find.text('Nem érhető el a szerver.'), findsNothing);
  });

  testWidgets('balra húzás és megerősítés után visszavonja a rangot',
      (tester) async {
    roles.getResult = Ok([
      summary(1, 'Teszt Elek', 'perpa4'),
      summary(2, 'Kiss Béla', 'kiss1'),
    ]);
    await _pump(tester, roles);

    await tester.drag(find.text('Kiss Béla'), const Offset(-600, 0));
    await tester.pumpAndSettle();
    expect(find.text('Rang visszavonása'), findsOneWidget);
    expect(roles.revokedIds, isEmpty);

    await tester.tap(find.text('Visszavonás'));
    await tester.pumpAndSettle();

    expect(roles.revokedIds, [2]);
    expect(find.text('Kiss Béla'), findsNothing);
    expect(find.text('Teszt Elek'), findsOneWidget);
  });

  testWidgets('sikertelen visszavonás: hibaüzenet és újratöltés',
      (tester) async {
    roles.getResult = Ok([summary(2, 'Kiss Béla', 'kiss1')]);
    roles.revokeResult = const Err('Nem sikerült visszavonni.');
    await _pump(tester, roles);

    await tester.drag(find.text('Kiss Béla'), const Offset(-600, 0));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Visszavonás'));
    await tester.pumpAndSettle();

    expect(find.text('Nem sikerült visszavonni.'), findsOneWidget);
    expect(roles.getCount, 2);
    expect(find.text('Kiss Béla'), findsOneWidget);
  });

  testWidgets('a kinevezés gomb alapból a fejlécben van, FAB módban nem',
      (tester) async {
    await _pump(tester, roles);
    expect(find.byIcon(Icons.add_rounded), findsOneWidget);
    expect(find.byType(Scaffold), findsOneWidget);
    expect(
        tester.widget<Scaffold>(find.byType(Scaffold)).floatingActionButton,
        isNull);

    await _pump(tester, roles, asFab: true);
    expect(find.byIcon(Icons.add_rounded), findsOneWidget);
    expect(
        tester.widget<Scaffold>(find.byType(Scaffold)).floatingActionButton,
        isNotNull);
  });
}
