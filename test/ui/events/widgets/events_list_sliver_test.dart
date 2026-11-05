import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:itk_app/ui/core/widgets/sliver_state_message.dart';
import 'package:itk_app/ui/events/widgets/events_list_sliver.dart';

Widget _wrap({
  String query = '',
  String? loadError,
  bool subjectFilterActive = false,
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

    testWidgets('plain empty state', (tester) async {
      await tester.pumpWidget(_wrap());

      expect(find.text('Nincs közelgő zh.'), findsOneWidget);
      expect(_message(tester).onRetry, isNull);
    });
  });
}
