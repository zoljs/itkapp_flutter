import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:itk_app/ui/core/widgets/brand_icon_button.dart';

Future<void> _pump(WidgetTester tester, {VoidCallback? onPressed}) =>
    tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Center(
          child: BrandIconButton(
            icon: Icons.add,
            semanticLabel: 'Hozzáadás',
            onPressed: onPressed,
          ),
        ),
      ),
    ));

void main() {
  testWidgets('tap calls onPressed', (tester) async {
    var taps = 0;
    await _pump(tester, onPressed: () => taps++);
    await tester.tap(find.byType(BrandIconButton));
    await tester.pumpAndSettle();
    expect(taps, 1);
  });

  testWidgets('label is announced once', (tester) async {
    final handle = tester.ensureSemantics();
    await _pump(tester, onPressed: () {});
    expect(find.bySemanticsLabel('Hozzáadás'), findsOneWidget);
    handle.dispose();
  });

  testWidgets('disabled is faded', (tester) async {
    await _pump(tester);
    final opacity = tester.widget<AnimatedOpacity>(find.descendant(
      of: find.byType(BrandIconButton),
      matching: find.byType(AnimatedOpacity),
    ));
    expect(opacity.opacity, 0.4);
  });
}
