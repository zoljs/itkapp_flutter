import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:itk_app/ui/calendar/widgets/calendar_planner.dart';

Future<void> _pump(
  WidgetTester tester, {
  required double height,
  String? location = '318',
  double textScale = 1,
}) =>
    tester.pumpWidget(MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
        child: Scaffold(
          body: Align(
            alignment: Alignment.topLeft,
            child: CalendarEventTile(
              title: 'Analízis I. (gyakorlat) - nagyon hosszú cím',
              location: location,
              height: height,
              width: 90,
            ),
          ),
        ),
      ),
    ));

void main() {
  // Pinch zoom makes tiles anything from a few pixels to very tall.
  for (final scale in [1.0, 1.5]) {
    for (final height in [
      2.0,
      6.0,
      12.0,
      18.0,
      24.0,
      34.0,
      45.0,
      60.0,
      120.0
    ]) {
      testWidgets('nincs túlcsordulás: magasság $height, szövegméret $scale',
          (tester) async {
        await _pump(tester, height: height, textScale: scale);
        expect(tester.takeException(), isNull);
      });
    }
  }

  testWidgets('nagyon alacsony csempén nincs szöveg, csak a szín',
      (tester) async {
    await _pump(tester, height: 8);
    expect(find.byType(Text), findsNothing);
  });

  testWidgets('egy sornyi helyen csak a cím látszik', (tester) async {
    await _pump(tester, height: 22);
    expect(find.textContaining('Analízis'), findsOneWidget);
    expect(find.text('318'), findsNothing);
  });

  testWidgets('magas csempén a cím és a helyszín is látszik', (tester) async {
    await _pump(tester, height: 80);
    expect(find.textContaining('Analízis'), findsOneWidget);
    expect(find.text('318'), findsOneWidget);
  });

  testWidgets('helyszín nélkül a cím két sort kaphat', (tester) async {
    await _pump(tester, height: 44, location: null);
    final title = tester.widget<Text>(find.textContaining('Analízis'));
    expect(title.maxLines, 2);
  });
}
