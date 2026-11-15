import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:itk_app/ui/core/widgets/settings_avatar_button.dart';
import 'package:itk_app/ui/core/widgets/user_avatar.dart';

Future<void> _pump(
  WidgetTester tester, {
  required VoidCallback onAvatarTap,
  String? login = 'perpa4',
}) =>
    tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Center(
          child: SettingsAvatarButton(onAvatarTap: onAvatarTap, login: login),
        ),
      ),
    ));

void main() {
  testWidgets('a login kezdőbetűje látszik az avatarban', (tester) async {
    await _pump(tester, onAvatarTap: () {});

    expect(find.byType(UserAvatar), findsOneWidget);
    expect(find.text('P'), findsOneWidget);
  });

  testWidgets('nincs login: U betű', (tester) async {
    await _pump(tester, onAvatarTap: () {}, login: null);

    expect(find.text('U'), findsOneWidget);
  });

  testWidgets('koppintásra az onAvatarTap meghívódik', (tester) async {
    var taps = 0;
    await _pump(tester, onAvatarTap: () => taps++);

    await tester.tap(find.byType(UserAvatar));
    await tester.pumpAndSettle();

    expect(taps, 1);
  });
}
