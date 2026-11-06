import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:itk_app/ui/core/widgets/rolling_text.dart';

Future<void> _pump(
  WidgetTester tester,
  String text, {
  bool forward = true,
  bool reduceMotion = false,
}) =>
    tester.pumpWidget(MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(disableAnimations: reduceMotion),
        child: Scaffold(body: RollingText(text, forward: forward)),
      ),
    ));

int _count(String char) =>
    find.text(char, skipOffstage: false).evaluate().length;

void main() {
  testWidgets('képernyőolvasó a teljes szöveget kapja meg', (tester) async {
    final handle = tester.ensureSemantics();
    await _pump(tester, 'nov. 5.');
    expect(find.bySemanticsLabel('nov. 5.'), findsOneWidget);
    handle.dispose();
  });

  testWidgets('csak a változó karakter gördül', (tester) async {
    await _pump(tester, 'nov. 5.');
    await _pump(tester, 'nov. 6.');
    await tester.pump(const Duration(milliseconds: 150));

    // Mid-animation: the old and the new digit are both on screen.
    expect(_count('5'), 1);
    expect(_count('6'), 1);
    // Unchanged characters are not duplicated.
    expect(_count('n'), 1);

    await tester.pumpAndSettle();
    expect(_count('5'), 0);
    expect(_count('6'), 1);
  });

  testWidgets('hosszabb szövegre váltás nem dob hibát', (tester) async {
    await _pump(tester, 'nov. 9.');
    await _pump(tester, 'nov. 10.', forward: true);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(_count('1'), 1);
    expect(_count('0'), 1);
  });

  testWidgets('csökkentett mozgásnál sima szöveg, nincs gördülés',
      (tester) async {
    await _pump(tester, 'nov. 5.', reduceMotion: true);
    expect(find.text('nov. 5.'), findsOneWidget);
    expect(find.byType(AnimatedSwitcher), findsNothing);
  });
}
