import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:itk_app/ui/core/widgets/user_avatar.dart';

Future<void> _pump(
  WidgetTester tester, {
  required String? login,
  double radius = 45,
  Color color = Colors.green,
}) =>
    tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Center(
          child: UserAvatar(login: login, radius: radius, color: color),
        ),
      ),
    ));

void main() {
  testWidgets('a login első betűje nagybetűvel látszik', (tester) async {
    await _pump(tester, login: 'perpa4');

    expect(find.text('P'), findsOneWidget);
  });

  testWidgets('nincs login: U betű', (tester) async {
    await _pump(tester, login: null);

    expect(find.text('U'), findsOneWidget);
  });

  testWidgets('üres login: U betű', (tester) async {
    await _pump(tester, login: '');

    expect(find.text('U'), findsOneWidget);
  });

  testWidgets('a megadott szín és sugár érvényesül', (tester) async {
    await _pump(tester, login: 'abc', radius: 20, color: Colors.purple);

    final avatar = tester.widget<CircleAvatar>(find.byType(CircleAvatar));
    expect(avatar.radius, 20);
    expect(avatar.backgroundColor, Colors.purple);
  });
}
