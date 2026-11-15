import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:itk_app/domain/models/calendar_link.dart';
import 'package:itk_app/ui/calendar/widgets/calendar_link_tile.dart';

Future<void> _pump(WidgetTester tester, CalendarLink link) =>
    tester.pumpWidget(MaterialApp(
      home: Scaffold(body: CalendarLinkTile(link: link)),
    ));

void main() {
  setUpAll(() => initializeDateFormatting('hu'));

  testWidgets('még nem szinkronizált naptár: a név és a figyelmeztetés látszik',
      (tester) async {
    await _pump(
      tester,
      const CalendarLink(
        id: 1,
        name: 'Neptun',
        url: 'https://example.com/1.ics',
        syncInterval: SyncInterval.daily,
      ),
    );

    expect(find.text('Neptun'), findsOneWidget);
    expect(find.text('Még nincs szinkronizálva.'), findsOneWidget);
  });

  testWidgets('szinkronizált naptár: az utolsó szinkron ideje látszik',
      (tester) async {
    await _pump(
      tester,
      CalendarLink(
        id: 2,
        name: 'Edzés',
        url: 'https://example.com/2.ics',
        syncInterval: SyncInterval.hourly,
        lastSyncedAt: DateTime(2026, 11, 10, 9, 30),
      ),
    );

    expect(find.text('Edzés'), findsOneWidget);
    expect(find.textContaining('Szinkronizálva:'), findsOneWidget);
    expect(find.textContaining('09:30'), findsOneWidget);
    expect(find.text('Még nincs szinkronizálva.'), findsNothing);
  });
}
