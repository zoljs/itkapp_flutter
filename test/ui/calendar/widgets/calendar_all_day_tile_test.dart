import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:itk_app/ui/calendar/widgets/calendar_planner.dart';

void main() {
  testWidgets('a cím és a megadott szélesség látszik', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: Align(
          alignment: Alignment.topLeft,
          child: CalendarAllDayTile(title: 'Tavaszi szünet', width: 120),
        ),
      ),
    ));

    expect(find.text('Tavaszi szünet'), findsOneWidget);
    expect(tester.getSize(find.byType(CalendarAllDayTile)).width, 120);
  });

  testWidgets('hosszú cím egy sorra vágódik, nem törik meg', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: Align(
          alignment: Alignment.topLeft,
          child: CalendarAllDayTile(
            title: 'Nagyon hosszú, egész napos esemény neve ami nem fér ki',
            width: 80,
          ),
        ),
      ),
    ));

    final text = tester.widget<Text>(find.byType(Text));
    expect(text.maxLines, 1);
    expect(text.overflow, TextOverflow.ellipsis);
    expect(tester.takeException(), isNull);
  });
}
