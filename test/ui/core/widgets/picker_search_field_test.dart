import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:itk_app/ui/core/widgets/picker_search_field.dart';

Future<void> _pump(
  WidgetTester tester, {
  required TextEditingController controller,
  required ValueChanged<String> onChanged,
}) =>
    tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: PickerSearchField(
          searchController: controller,
          onChanged: onChanged,
          hintText: 'Tárgy keresése...',
        ),
      ),
    ));

void main() {
  testWidgets('üres mezőnél a hint és a keresés ikon látszik, törlés nincs',
      (tester) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);
    await _pump(tester, controller: controller, onChanged: (_) {});

    expect(find.text('Tárgy keresése...'), findsOneWidget);
    expect(find.byIcon(Icons.search_rounded), findsOneWidget);
    expect(find.byIcon(Icons.close_rounded), findsNothing);
  });

  testWidgets('gépeléskor az onChanged megkapja a szöveget és megjelenik a törlés',
      (tester) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);
    final changes = <String>[];
    await _pump(tester, controller: controller, onChanged: changes.add);

    await tester.enterText(find.byType(TextField), 'anal');
    await tester.pump();

    expect(changes, ['anal']);
    expect(find.byIcon(Icons.close_rounded), findsOneWidget);
  });

  testWidgets('a törlés gomb üríti a mezőt és üres szöveggel értesít',
      (tester) async {
    final controller = TextEditingController(text: 'anal');
    addTearDown(controller.dispose);
    final changes = <String>[];
    await _pump(tester, controller: controller, onChanged: changes.add);

    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pump();

    expect(controller.text, isEmpty);
    expect(changes, ['']);
    expect(find.byIcon(Icons.close_rounded), findsNothing);
  });
}
