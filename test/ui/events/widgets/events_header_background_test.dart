import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:itk_app/ui/events/widgets/events_header_background.dart';
import 'package:itk_app/ui/events/widgets/weekstrip.dart';

Future<void> _pump(WidgetTester tester, {double bottomInset = 100}) =>
    tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SizedBox(
          height: 400,
          child: EventsHeaderBackground(bottomInset: bottomInset),
        ),
      ),
    ));

/// The blue box is the first ColoredBox inside the header. A plain
/// `find.byType(ColoredBox)` would also match the ones from MaterialApp.
Rect _blueBox(WidgetTester tester) => tester.getRect(find
    .descendant(
      of: find.byType(EventsHeaderBackground),
      matching: find.byType(ColoredBox),
    )
    .first);

void main() {
  setUpAll(() => initializeDateFormatting('hu'));

  testWidgets('megjeleníti a mai dátumot és a hét sávját', (tester) async {
    await _pump(tester);

    final today = DateFormat('MMM d.', 'hu').format(DateTime.now());
    expect(find.textContaining(today), findsOneWidget);
    expect(find.byType(WeekStrip), findsOneWidget);
  });

  testWidgets('a háttér a bottomInset-ig ér', (tester) async {
    await _pump(tester, bottomInset: 100);

    final background = _blueBox(tester);
    final header = tester.getRect(find.byType(EventsHeaderBackground));

    expect(header.bottom - background.bottom, 100);
  });

  testWidgets('a háttér magassága követi a bottomInset változását',
      (tester) async {
    await _pump(tester, bottomInset: 60);
    final small = _blueBox(tester).height;

    await _pump(tester, bottomInset: 160);
    final large = _blueBox(tester).height;

    expect(small - large, 100);
  });
}
