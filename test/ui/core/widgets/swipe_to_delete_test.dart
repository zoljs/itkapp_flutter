import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:itk_app/ui/core/widgets/swipe_to_delete.dart';

Future<void> _pump(WidgetTester tester, {required VoidCallback onDelete}) {
  // HapticFeedback talks to a platform channel that does not exist in tests.
  tester.binding.defaultBinaryMessenger
      .setMockMethodCallHandler(SystemChannels.platform, (call) async => null);
  addTearDown(() => tester.binding.defaultBinaryMessenger
      .setMockMethodCallHandler(SystemChannels.platform, null));

  return tester.pumpWidget(MaterialApp(
    home: Scaffold(
      body: SwipeToDelete(
        id: 1,
        confirmTitle: 'Elem törlése',
        confirmMessage: 'Biztosan törlöd?',
        onDelete: onDelete,
        child: const SizedBox(height: 80, child: Center(child: Text('Elem'))),
      ),
    ),
  ));
}

Future<void> _swipeLeft(WidgetTester tester) async {
  await tester.drag(find.text('Elem'), const Offset(-600, 0));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('balra húzva megerősítő ablak jön, még nem töröl',
      (tester) async {
    var deleted = 0;
    await _pump(tester, onDelete: () => deleted++);

    await _swipeLeft(tester);

    expect(find.text('Elem törlése'), findsOneWidget);
    expect(find.text('Biztosan törlöd?'), findsOneWidget);
    expect(deleted, 0);
  });

  testWidgets('mégse: nem hívja az onDelete-et, az elem marad',
      (tester) async {
    var deleted = 0;
    await _pump(tester, onDelete: () => deleted++);

    await _swipeLeft(tester);
    await tester.tap(find.text('Mégse'));
    await tester.pumpAndSettle();

    expect(deleted, 0);
    expect(find.text('Elem'), findsOneWidget);
  });

  testWidgets('megerősítés: pontosan egyszer hívja az onDelete-et',
      (tester) async {
    var deleted = 0;
    await _pump(tester, onDelete: () => deleted++);

    await _swipeLeft(tester);
    await tester.tap(find.widgetWithText(FilledButton, 'Törlés'));
    await tester.pumpAndSettle();

    expect(deleted, 1);
  });

  testWidgets('jobbra húzva nincs megerősítő ablak', (tester) async {
    var deleted = 0;
    await _pump(tester, onDelete: () => deleted++);

    await tester.drag(find.text('Elem'), const Offset(600, 0));
    await tester.pumpAndSettle();

    expect(find.text('Elem törlése'), findsNothing);
    expect(deleted, 0);
  });
}
