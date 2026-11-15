import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:itk_app/domain/models/calendar_event.dart';
import 'package:itk_app/ui/home/widgets/next_class_card.dart';

Future<void> _pump(
  WidgetTester tester, {
  required CalendarEvent event,
  String day = 'Ma',
  String time = '09:05 - 10:35',
}) =>
    tester.pumpWidget(MaterialApp(
      home: Builder(
        builder: (context) => Scaffold(
          body: NextClassCard(
            e: event,
            scheme: Theme.of(context).colorScheme,
            day: day,
            muted: const TextStyle(fontSize: 13),
            time: time,
          ),
        ),
      ),
    ));

CalendarEvent _event({String? location}) => CalendarEvent(
      title: 'Analízis I. (gyakorlat)',
      start: DateTime(2026, 11, 16, 9, 5),
      end: DateTime(2026, 11, 16, 10, 35),
      location: location,
    );

void main() {
  testWidgets('a kezdés órája, a nap, a cím és az idősáv látszik',
      (tester) async {
    await _pump(tester, event: _event());

    expect(find.text('09:05'), findsOneWidget);
    expect(find.text('Ma'), findsOneWidget);
    expect(find.text('Analízis I. (gyakorlat)'), findsOneWidget);
    expect(find.text('09:05 - 10:35'), findsOneWidget);
  });

  testWidgets('helyszínnel az idősáv után jön, pontokkal elválasztva',
      (tester) async {
    await _pump(tester, event: _event(location: '318'));

    expect(find.text('09:05 - 10:35 · 318'), findsOneWidget);
  });

  testWidgets('üres helyszín nem kerül ki', (tester) async {
    await _pump(tester, event: _event(location: ''));

    expect(find.text('09:05 - 10:35'), findsOneWidget);
    expect(find.textContaining('·'), findsNothing);
  });
}
