import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:itk_app/ui/core/widgets/sliver_state_message.dart';

Future<void> _pump(
  WidgetTester tester, {
  String message = 'Nincs találat.',
  VoidCallback? onRetry,
}) =>
    tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: CustomScrollView(
          slivers: [
            SliverStateMessage(
              icon: Icons.search_off_rounded,
              message: message,
              onRetry: onRetry,
            ),
          ],
        ),
      ),
    ));

void main() {
  testWidgets('megjeleníti az ikont és az üzenetet', (tester) async {
    await _pump(tester, message: 'Még nincs oldal.');

    expect(find.text('Még nincs oldal.'), findsOneWidget);
    expect(find.byIcon(Icons.search_off_rounded), findsOneWidget);
  });

  testWidgets('onRetry nélkül nincs Újra gomb', (tester) async {
    await _pump(tester);

    expect(find.text('Újra'), findsNothing);
  });

  testWidgets('onRetry esetén az Újra gomb meghívja', (tester) async {
    var retries = 0;
    await _pump(tester, onRetry: () => retries++);

    await tester.tap(find.text('Újra'));

    expect(retries, 1);
  });
}
