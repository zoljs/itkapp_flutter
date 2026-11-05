import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:itk_app/ui/core/widgets/sliver_state_message.dart';
import 'package:itk_app/ui/events/widgets/events_list_sliver.dart';

Widget _wrap({
  String query = '',
  String? loadError,
  bool subjectFilterActive = false,
  bool timeRangeActive = false,
}) =>
    MaterialApp(
      home: Scaffold(
        body: CustomScrollView(
          slivers: [
            EventsListSliver(
              events: const [],
              loading: false,
              query: query,
              loadError: loadError,
              subjectFilterActive: subjectFilterActive,
              timeRangeActive: timeRangeActive,
              eventLabel: 'zh',
              canDelete: false,
              onRetry: () {},
              onDelete: (_) async {},
            ),
          ],
        ),
      ),
    );

SliverStateMessage _message(WidgetTester tester) =>
    tester.widget<SliverStateMessage>(find.byType(SliverStateMessage));

void main() {
  group('EventsListSliver empty state', () {
    testWidgets('load error shows the error and retry', (tester) async {
      await tester.pumpWidget(_wrap(loadError: 'Hiba történt'));

      expect(find.textContaining('Hiba történt'), findsOneWidget);
      expect(_message(tester).onRetry, isNotNull);
    });

    testWidgets('load error wins over query', (tester) async {
      await tester.pumpWidget(_wrap(loadError: 'Hiba történt', query: 'abc'));

      expect(find.textContaining('Hiba történt'), findsOneWidget);
      expect(find.textContaining('Nincs találat erre'), findsNothing);
    });

    testWidgets('query shows no-result message, no retry', (tester) async {
      await tester.pumpWidget(_wrap(query: 'abc'));

      expect(find.textContaining('Nincs találat erre'), findsOneWidget);
      expect(find.textContaining('abc'), findsOneWidget);
      expect(_message(tester).onRetry, isNull);
    });

    testWidgets('subject filter active names the subjects', (tester) async {
      await tester.pumpWidget(_wrap(subjectFilterActive: true));

      expect(find.textContaining('a tárgyaidból'), findsOneWidget);
    });

    testWidgets('icons: error, search and empty each have their own',
        (tester) async {
      await tester.pumpWidget(_wrap(loadError: 'Hiba történt'));
      expect(_message(tester).icon, Icons.cloud_off_rounded);

      await tester.pumpWidget(_wrap(query: 'abc'));
      expect(_message(tester).icon, Icons.search_off_rounded);

      await tester.pumpWidget(_wrap());
      expect(_message(tester).icon, Icons.event_available_rounded);
    });

    testWidgets('time range active names the range', (tester) async {
      await tester.pumpWidget(_wrap(timeRangeActive: true));

      expect(find.text('Nincs közelgő zh a kiválasztott időszakban.'),
          findsOneWidget);
      expect(_message(tester).onRetry, isNull);
    });

    testWidgets('subject filter and time range both named', (tester) async {
      await tester
          .pumpWidget(_wrap(subjectFilterActive: true, timeRangeActive: true));

      expect(
          find.text(
              'Nincs közelgő zh a tárgyaidból a kiválasztott időszakban.'),
          findsOneWidget);
    });

    testWidgets('query wins over the filter flags', (tester) async {
      await tester.pumpWidget(_wrap(
          query: 'abc', subjectFilterActive: true, timeRangeActive: true));

      expect(find.textContaining('Nincs találat erre'), findsOneWidget);
      expect(find.textContaining('kiválasztott időszakban'), findsNothing);
    });

    testWidgets('plain empty state', (tester) async {
      await tester.pumpWidget(_wrap());

      expect(find.text('Nincs közelgő zh.'), findsOneWidget);
      expect(_message(tester).onRetry, isNull);
    });
  });
}
