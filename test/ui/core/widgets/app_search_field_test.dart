import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:itk_app/ui/core/widgets/app_search_field.dart';

Future<void> _pump(
  WidgetTester tester, {
  required TextEditingController controller,
  required ValueChanged<String> onChanged,
}) =>
    tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: AppSearchField(
          searchController: controller,
          onChanged: onChanged,
          hintText: 'Keresés...',
        ),
      ),
    ));

void main() {
  testWidgets('üres mezőnél a hint látszik, törlés gomb nincs', (tester) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);
    await _pump(tester, controller: controller, onChanged: (_) {});

    expect(find.text('Keresés...'), findsOneWidget);
    expect(find.byIcon(Icons.close_rounded), findsNothing);
  });

  testWidgets('gépeléskor az onChanged megkapja a szöveget', (tester) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);
    final changes = <String>[];
    await _pump(tester, controller: controller, onChanged: changes.add);

    await tester.enterText(find.byType(TextField), 'anal');

    expect(changes, ['anal']);
  });

  testWidgets('kitöltött mezőnél a törlés gomb látszik', (tester) async {
    final controller = TextEditingController(text: 'anal');
    addTearDown(controller.dispose);
    await _pump(tester, controller: controller, onChanged: (_) {});

    expect(find.byIcon(Icons.close_rounded), findsOneWidget);
  });

  testWidgets(
      'a törlés gomb üríti a mezőt és üres szöveggel hívja az onChanged-et',
      (tester) async {
    final controller = TextEditingController(text: 'anal');
    addTearDown(controller.dispose);
    final changes = <String>[];
    await _pump(tester, controller: controller, onChanged: changes.add);

    await tester.tap(find.byIcon(Icons.close_rounded));

    expect(controller.text, isEmpty);
    expect(changes, ['']);
  });


  testWidgets(
      'gépelésre megjelenik a törlés gomb, a szülő újraépítése nélkül',
      (tester) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);
    // onChanged does nothing, so nothing rebuilds the parent.
    await _pump(tester, controller: controller, onChanged: (_) {});
    expect(find.byIcon(Icons.close_rounded), findsNothing);

    await tester.enterText(find.byType(TextField), 'anal');
    await tester.pump();

    expect(find.byIcon(Icons.close_rounded), findsOneWidget);
  });

  testWidgets('a törlés gomb eltűnik, ha kiürül a mező', (tester) async {
    final controller = TextEditingController(text: 'anal');
    addTearDown(controller.dispose);
    await _pump(tester, controller: controller, onChanged: (_) {});

    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pump();

    expect(find.byIcon(Icons.close_rounded), findsNothing);
  });
}
