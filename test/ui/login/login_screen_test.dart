import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:itk_app/data/repositories/auth_repository.dart';
import 'package:itk_app/ui/login/login_screen.dart';
import 'package:itk_app/utils/result.dart';
import 'package:provider/provider.dart';

import '../../helpers/fake_repositories.dart';

const _usernameHint = 'Shibboleth ID (pl. naszy)';
const _passwordHint = 'Jelszó';

Future<void> _pump(WidgetTester tester, FakeAuthRepository auth) =>
    tester.pumpWidget(ChangeNotifierProvider<AuthRepository>.value(
      value: auth,
      child: const MaterialApp(home: LoginScreen()),
    ));

Finder _field(String hint) =>
    find.widgetWithText(TextFormField, hint, skipOffstage: false);

bool _passwordObscured(WidgetTester tester) => tester
    .widget<EditableText>(find.descendant(
      of: _field(_passwordHint),
      matching: find.byType(EditableText),
    ))
    .obscureText;

void main() {
  late FakeAuthRepository auth;

  setUp(() => auth = FakeAuthRepository());

  testWidgets('a cím, a két mező és a gomb látszik', (tester) async {
    await _pump(tester, auth);

    expect(find.text('Üdvözlünk újra'), findsOneWidget);
    expect(find.text(_usernameHint), findsOneWidget);
    expect(find.text(_passwordHint), findsOneWidget);
    expect(find.text('Bejelentkezés'), findsOneWidget);
  });

  testWidgets('üres mezőkkel hibaüzenetek jönnek, nincs bejelentkezés',
      (tester) async {
    await _pump(tester, auth);

    await tester.tap(find.text('Bejelentkezés'));
    await tester.pumpAndSettle();

    expect(find.text('Kérlek, add meg a felhasználóneved.'), findsOneWidget);
    expect(find.text('Kérlek, add meg a jelszavad.'), findsOneWidget);
    expect(auth.logins, isEmpty);
  });

  testWidgets('csak szóközből álló felhasználónév is hibás', (tester) async {
    await _pump(tester, auth);

    await tester.enterText(_field(_usernameHint), '   ');
    await tester.enterText(_field(_passwordHint), 'titok');
    await tester.tap(find.text('Bejelentkezés'));
    await tester.pumpAndSettle();

    expect(find.text('Kérlek, add meg a felhasználóneved.'), findsOneWidget);
    expect(auth.logins, isEmpty);
  });

  testWidgets('érvényes adatokkal bejelentkeztet, a felhasználónevet vágja',
      (tester) async {
    await _pump(tester, auth);

    await tester.enterText(_field(_usernameHint), '  perpa4 ');
    await tester.enterText(_field(_passwordHint), 'titok');
    await tester.tap(find.text('Bejelentkezés'));
    await tester.pumpAndSettle();

    expect(auth.logins, [('perpa4', 'titok')]);
    expect(find.text('Kérlek, add meg a jelszavad.'), findsNothing);
  });

  testWidgets('a jelszó mező Done gombja is beküld', (tester) async {
    await _pump(tester, auth);

    await tester.enterText(_field(_usernameHint), 'perpa4');
    await tester.enterText(_field(_passwordHint), 'titok');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    expect(auth.logins, [('perpa4', 'titok')]);
  });

  testWidgets('sikertelen bejelentkezés: a hibaüzenet megjelenik',
      (tester) async {
    auth.loginResult = const Err('Hibás felhasználónév vagy jelszó!');
    await _pump(tester, auth);

    await tester.enterText(_field(_usernameHint), 'perpa4');
    await tester.enterText(_field(_passwordHint), 'rossz');
    await tester.tap(find.text('Bejelentkezés'));
    await tester.pumpAndSettle();

    expect(find.text('Hibás felhasználónév vagy jelszó!'), findsOneWidget);
  });

  testWidgets('a szem ikon megmutatja és elrejti a jelszót', (tester) async {
    await _pump(tester, auth);
    expect(_passwordObscured(tester), isTrue);

    await tester.tap(find.byIcon(Icons.visibility_off_outlined));
    await tester.pump();
    expect(_passwordObscured(tester), isFalse);

    await tester.tap(find.byIcon(Icons.visibility_outlined));
    await tester.pump();
    expect(_passwordObscured(tester), isTrue);
  });
}
