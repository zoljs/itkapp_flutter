import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:itk_app/data/repositories/calendar_links_repository.dart';
import 'package:itk_app/data/repositories/calendar_repository.dart';
import 'package:itk_app/domain/models/calendar_link.dart';
import 'package:itk_app/ui/calendar/calendar_links_screen.dart';
import 'package:itk_app/ui/calendar/widgets/calendar_link_tile.dart';
import 'package:itk_app/utils/result.dart';
import 'package:provider/provider.dart';

import '../../helpers/fake_repositories.dart';
import '../../helpers/fixtures.dart';

const _nameHint = 'Név, pl. Neptun';

void main() {
  late FakeCalendarLinksRepository links;
  late FakeCalendarRepository calendar;

  setUp(() {
    links = FakeCalendarLinksRepository();
    calendar = FakeCalendarRepository();
  });

  Future<void> pump(WidgetTester tester) async {
    // Tall viewport: the whole ListView is built, no scrolling needed.
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(800, 2400);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(MultiProvider(
      providers: [
        Provider<CalendarLinksRepository>.value(value: links),
        ChangeNotifierProvider<CalendarRepository>.value(value: calendar),
      ],
      child: const MaterialApp(home: CalendarLinksScreen()),
    ));
    await tester.pumpAndSettle();
  }

  Finder nameField() => find.byType(TextField).at(0);
  Finder urlField() => find.byType(TextField).at(1);

  Future<void> tapAdd(WidgetTester tester) async {
    await tester.tap(find.text('Hozzáadás'));
    await tester.pumpAndSettle();
  }

  group('lista', () {
    testWidgets('a meglévő naptárak látszanak', (tester) async {
      links.getResult = Ok([
        link(id: 1, name: 'Edzés'),
        link(id: 2, name: 'Tanterv'),
      ]);

      await pump(tester);

      expect(find.text('Naptárlinkek'), findsOneWidget);
      expect(find.byType(CalendarLinkTile), findsNWidgets(2));
      expect(find.text('Edzés'), findsOneWidget);
      expect(find.text('Tanterv'), findsOneWidget);
    });

    testWidgets('üres lista: nincs naptár sor', (tester) async {
      await pump(tester);

      expect(find.byType(CalendarLinkTile), findsNothing);
    });

    testWidgets('betöltési hiba: üzenet és Újra gomb, ami újratölt',
        (tester) async {
      links.getResult = const Err('Nem érhető el a szerver.');
      await pump(tester);

      expect(find.text('Nem érhető el a szerver.'), findsOneWidget);
      expect(links.getCount, 1);

      links.getResult = Ok([link(id: 1, name: 'Edzés')]);
      await tester.tap(find.text('Újra'));
      await tester.pumpAndSettle();

      expect(links.getCount, 2);
      expect(find.text('Edzés'), findsOneWidget);
      expect(find.text('Nem érhető el a szerver.'), findsNothing);
    });
  });

  group('hozzáadás', () {
    testWidgets('üres mezőkkel a gomb nem csinál semmit', (tester) async {
      await pump(tester);

      await tapAdd(tester);

      expect(links.lastAdd, isNull);
    });

    testWidgets('csak névvel még nem lehet menteni', (tester) async {
      await pump(tester);

      await tester.enterText(nameField(), 'Edzés');
      await tester.pump();
      await tapAdd(tester);

      expect(links.lastAdd, isNull);
    });

    testWidgets('a megadott adatokkal hív, ürít és üzenetet ad',
        (tester) async {
      await pump(tester);

      await tester.enterText(nameField(), '  Edzés ');
      await tester.enterText(urlField(), ' https://example.com/e.ics ');
      await tester.pump();
      await tapAdd(tester);

      expect(links.lastAdd, (
        name: 'Edzés',
        url: 'https://example.com/e.ics',
        syncInterval: SyncInterval.daily,
      ));
      expect(find.text('Naptár hozzáadva!'), findsOneWidget);
      expect(find.text(_nameHint), findsOneWidget);
      expect(calendar.invalidateCount, 1);
    });

    testWidgets('a preset chip kitölti a nevet', (tester) async {
      await pump(tester);

      await tester.tap(find.widgetWithText(ActionChip, 'Moodle'));
      await tester.pump();
      await tester.enterText(urlField(), 'https://example.com/m.ics');
      await tester.pump();
      await tapAdd(tester);

      expect(links.lastAdd?.name, 'Moodle');
    });

    testWidgets('a kiválasztott gyakoriság elmegy a kéréssel', (tester) async {
      await pump(tester);

      await tester.enterText(nameField(), 'Edzés');
      await tester.enterText(urlField(), 'https://example.com/e.ics');
      await tester.tap(find.text(SyncInterval.hourly.label));
      await tester.pump();
      await tapAdd(tester);

      expect(links.lastAdd?.syncInterval, SyncInterval.hourly);
    });

    testWidgets('szerverhiba: üzenet, a mezők megmaradnak', (tester) async {
      links.addResult = const Err('Ez a naptár már hozzá van adva.');
      await pump(tester);

      await tester.enterText(nameField(), 'Edzés');
      await tester.enterText(urlField(), 'https://example.com/e.ics');
      await tester.pump();
      await tapAdd(tester);

      expect(find.text('Ez a naptár már hozzá van adva.'), findsOneWidget);
      expect(find.text('Naptár hozzáadva!'), findsNothing);
      expect(find.text('Edzés'), findsOneWidget);
      expect(calendar.invalidateCount, 0);
    });

    testWidgets('10 naptárnál megtelt: nem lehet újat hozzáadni',
        (tester) async {
      links.getResult = Ok([
        for (var i = 1; i <= 10; i++) link(id: i, name: 'Naptar $i'),
      ]);
      await pump(tester);

      await tester.enterText(nameField(), 'Edzés');
      await tester.enterText(urlField(), 'https://example.com/e.ics');
      await tester.pump();
      await tapAdd(tester);

      expect(links.lastAdd, isNull);
    });
  });

  group('törlés', () {
    testWidgets('megerősítés után törli és üzenetet ad', (tester) async {
      links.getResult = Ok([
        link(id: 1, name: 'Edzés'),
        link(id: 2, name: 'Tanterv'),
      ]);
      await pump(tester);

      await tester.drag(find.text('Tanterv'), const Offset(-600, 0));
      await tester.pumpAndSettle();
      expect(find.text('Naptár törlése'), findsOneWidget);
      expect(links.deletedIds, isEmpty);

      await tester.tap(find.text('Törlés'));
      await tester.pumpAndSettle();

      expect(links.deletedIds, [2]);
      expect(find.text('Naptár törölve!'), findsOneWidget);
      expect(calendar.invalidateCount, 1);
    });

    testWidgets('sikertelen törlés: hibaüzenet', (tester) async {
      links.getResult = Ok([link(id: 1, name: 'Edzés')]);
      links.deleteResult = const Err('Nem sikerült törölni.');
      await pump(tester);

      await tester.drag(find.text('Edzés'), const Offset(-600, 0));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Törlés'));
      await tester.pumpAndSettle();

      expect(find.text('Nem sikerült törölni.'), findsOneWidget);
      expect(find.text('Naptár törölve!'), findsNothing);
    });
  });
}
