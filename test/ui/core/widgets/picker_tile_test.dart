import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:itk_app/ui/core/widgets/picker_tile.dart';

Future<void> _pump(
  WidgetTester tester, {
  VoidCallback? onTap,
  Widget? trailing,
}) =>
    tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: PickerTile(
          title: 'Analízis I.',
          subtitle: 'ITK101',
          onTap: onTap,
          trailing: trailing,
        ),
      ),
    ));

ColorScheme _scheme(WidgetTester tester) =>
    Theme.of(tester.element(find.byType(PickerTile))).colorScheme;

void main() {
  testWidgets('a cím és az alcím látszik', (tester) async {
    await _pump(tester, onTap: () {});

    expect(find.text('Analízis I.'), findsOneWidget);
    expect(find.text('ITK101'), findsOneWidget);
  });

  testWidgets('koppintás hívja az onTap-et', (tester) async {
    var taps = 0;
    await _pump(tester, onTap: () => taps++);

    await tester.tap(find.byType(PickerTile));

    expect(taps, 1);
  });

  testWidgets('a trailing widget látszik, ha van', (tester) async {
    await _pump(tester,
        onTap: () {}, trailing: const Icon(Icons.check_rounded));

    expect(find.byIcon(Icons.check_rounded), findsOneWidget);
  });

  testWidgets('trailing nélkül nincs extra ikon', (tester) async {
    await _pump(tester, onTap: () {});

    expect(find.byType(Icon), findsNothing);
  });

  testWidgets('onTap nélkül a cím halvány, és a koppintás nem csinál semmit',
      (tester) async {
    await _pump(tester);

    final title = tester.widget<Text>(find.text('Analízis I.'));
    expect(title.style?.color, _scheme(tester).onSurfaceVariant);

    await tester.tap(find.byType(PickerTile));
    await tester.pump();
  });

  testWidgets('aktív sornál a cím a normál színt kapja', (tester) async {
    await _pump(tester, onTap: () {});

    final title = tester.widget<Text>(find.text('Analízis I.'));
    expect(title.style?.color, _scheme(tester).onSurface);
  });

  testWidgets('a sor legalább 64 magas', (tester) async {
    await _pump(tester, onTap: () {});

    expect(tester.getSize(find.byType(PickerTile)).height,
        greaterThanOrEqualTo(64));
  });
}
