import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:itk_app/data/repositories/admin/admin_users_repository.dart';
import 'package:itk_app/domain/models/user_summary.dart';
import 'package:itk_app/ui/admin/user_picker_screen.dart';
import 'package:itk_app/utils/result.dart';
import 'package:provider/provider.dart';

import '../../helpers/fake_repositories.dart';
import '../../helpers/fixtures.dart';

/// The picker sits on a pushed route, so closing it leads back to a page.
Widget _app(FakeAdminUsersRepository users, UserPickerScreen picker) =>
    Provider<AdminUsersRepository>.value(
      value: users,
      child: MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => Navigator.push<void>(
                  context,
                  MaterialPageRoute(builder: (_) => picker),
                ),
                child: const Text('Megnyit'),
              ),
            ),
          ),
        ),
      ),
    );

Future<void> _open(WidgetTester tester) async {
  await tester.tap(find.text('Megnyit'));
  await tester.pumpAndSettle();
}

void main() {
  late FakeAdminUsersRepository users;

  setUp(() {
    users = FakeAdminUsersRepository()
      ..getResult = Ok([
        summary(1, 'Teszt Elek', 'perpa4'),
        summary(2, 'Kiss Béla', 'kiss1'),
      ]);
  });

  testWidgets('a felhasználók neve és loginja látszik', (tester) async {
    await tester.pumpWidget(_app(users, UserPickerScreen(onPicked: (_) {})));
    await _open(tester);

    expect(find.text('Felhasználó'), findsOneWidget);
    expect(find.text('Teszt Elek'), findsOneWidget);
    expect(find.text('perpa4'), findsOneWidget);
    expect(find.text('Kiss Béla'), findsOneWidget);
  });

  testWidgets('a keresés névre és loginra szűr', (tester) async {
    await tester.pumpWidget(_app(users, UserPickerScreen(onPicked: (_) {})));
    await _open(tester);

    await tester.enterText(find.byType(TextField), 'kiss');
    await tester.pump();
    expect(find.text('Teszt Elek'), findsNothing);
    expect(find.text('Kiss Béla'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'PERPA');
    await tester.pump();
    expect(find.text('Teszt Elek'), findsOneWidget);
    expect(find.text('Kiss Béla'), findsNothing);
  });

  testWidgets('a már kinevezett felhasználó jelölt és nem választható',
      (tester) async {
    final picked = <UserSummary>[];
    await tester.pumpWidget(_app(
      users,
      UserPickerScreen(onPicked: picked.add, excludedIds: const {1}),
    ));
    await _open(tester);

    expect(find.textContaining('már évfolyamfelelős'), findsOneWidget);
    expect(find.byIcon(Icons.check_rounded), findsOneWidget);

    await tester.tap(find.text('Teszt Elek'));
    await tester.pumpAndSettle();

    expect(picked, isEmpty);
  });

  testWidgets('választáskor az onPicked a felhasználót kapja', (tester) async {
    final picked = <UserSummary>[];
    await tester.pumpWidget(_app(users, UserPickerScreen(onPicked: picked.add)));
    await _open(tester);

    await tester.tap(find.text('Kiss Béla'));
    await tester.pumpAndSettle();

    expect(picked.map((u) => u.userId), [2]);
  });

  testWidgets('hiba esetén üzenet és Újra gomb', (tester) async {
    users.getResult = const Err('Nem érhető el a szerver.');
    await tester.pumpWidget(_app(users, UserPickerScreen(onPicked: (_) {})));
    await _open(tester);

    expect(find.text('Nem érhető el a szerver.'), findsOneWidget);

    users.getResult = Ok([summary(1, 'Teszt Elek', 'perpa4')]);
    await tester.tap(find.text('Újra'));
    await tester.pumpAndSettle();

    expect(find.text('Teszt Elek'), findsOneWidget);
  });
}
