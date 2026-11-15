import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:itk_app/domain/models/event.dart';
import 'package:itk_app/ui/core/widgets/sliver_state_message.dart';
import 'package:itk_app/ui/events/widgets/event_list_card.dart';
import 'package:itk_app/ui/events/widgets/events_list_sliver.dart';

import '../../../helpers/fixtures.dart';

final _events = [
  event(id: 1, subject: analysis, location: 'A-101'),
  event(id: 2, subject: programming, location: 'B-202'),
];

Widget _wrap({
  List<Event>? events,
  bool loading = false,
  bool canDelete = false,
  Future<bool> Function(Event event)? onDelete,
}) =>
    MaterialApp(
      home: Scaffold(
        body: CustomScrollView(
          slivers: [
            EventsListSliver(
              events: events ?? _events,
              loading: loading,
              query: '',
              loadError: null,
              subjectFilterActive: false,
              timeRangeActive: false,
              eventLabel: 'zh',
              canDelete: canDelete,
              onRetry: () {},
              onDelete: onDelete ?? (_) async => true,
            ),
          ],
        ),
      ),
    );

void main() {
  testWidgets('adatnál minden eseményhez van kártya, üzenet nincs',
      (tester) async {
    await tester.pumpWidget(_wrap());

    expect(find.byType(EventListCard), findsNWidgets(2));
    expect(find.text('Analízis I.'), findsOneWidget);
    expect(find.text('Programozás alapjai'), findsOneWidget);
    expect(find.byType(SliverStateMessage), findsNothing);
  });

  testWidgets('canDelete nélkül nincs csúsztatható kártya', (tester) async {
    await tester.pumpWidget(_wrap(canDelete: false));

    expect(find.byType(Dismissible), findsNothing);
  });

  testWidgets('canDelete esetén minden kártya csúsztatható', (tester) async {
    await tester.pumpWidget(_wrap(canDelete: true));

    expect(find.byType(Dismissible), findsNWidgets(2));
  });

  testWidgets('törlés megerősítése után az onDelete az eseményt kapja',
      (tester) async {
    final deleted = <int>[];
    await tester.pumpWidget(_wrap(
      canDelete: true,
      onDelete: (event) async {
        deleted.add(event.id);
        return true;
      },
    ));

    await tester.drag(find.text('Analízis I.'), const Offset(-600, 0));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Törlés'));
    await tester.pumpAndSettle();

    expect(deleted, [1]);
  });

  testWidgets('töltés közben vázak látszanak: nincs valódi adat és törlés',
      (tester) async {
    await tester.pumpWidget(_wrap(loading: true, canDelete: true));

    expect(find.byType(EventListCard), findsNWidgets(4));
    expect(find.text('Analízis I.'), findsNothing);
    expect(find.byType(Dismissible), findsNothing);
    expect(find.byType(SliverStateMessage), findsNothing);
  });

  testWidgets('töltés közben az üres lista sem mutat üzenetet',
      (tester) async {
    await tester.pumpWidget(_wrap(loading: true, events: const []));

    expect(find.byType(SliverStateMessage), findsNothing);
    expect(find.byType(EventListCard), findsNWidgets(4));
  });
}
