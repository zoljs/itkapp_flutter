import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:itk_app/data/repositories/auth_repository.dart';
import 'package:itk_app/data/repositories/calendar_repository.dart';
import 'package:itk_app/data/repositories/event_repository.dart';
import 'package:itk_app/data/repositories/theme_repository.dart';
import 'package:itk_app/domain/models/event.dart';
import 'package:itk_app/ui/core/widgets/offline_banner.dart';
import 'package:itk_app/ui/events/events_screen.dart';
import 'package:itk_app/ui/events/widgets/event_list_card.dart';
import 'package:itk_app/ui/events/widgets/events_header.dart';
import 'package:itk_app/utils/result.dart';
import 'package:provider/provider.dart';

import '../../helpers/fake_repositories.dart';
import '../../helpers/fixtures.dart';
import '../../helpers/prefs.dart';

const _disclaimer =
    'Ez egy évfolyamfelelősök által kezelt lista. Az itt szereplő információ helyességéért nem vállalunk felelősséget.';

void main() {
  setUpAll(() => initializeDateFormatting('hu'));

  late FakeEventRepository events;
  late FakeAuthRepository auth;
  late FakeCalendarRepository calendar;

  setUp(() {
    events = FakeEventRepository();
    auth = FakeAuthRepository()..cachedUser = user();
    calendar = FakeCalendarRepository();
  });

  Future<void> pump(WidgetTester tester, {bool asFab = false}) async {
    final theme = await makeThemeRepository(actionButtonAsFab: asFab);
    await tester.pumpWidget(MultiProvider(
      providers: [
        Provider<EventRepository>.value(value: events),
        ChangeNotifierProvider<AuthRepository>.value(value: auth),
        ChangeNotifierProvider<CalendarRepository>.value(value: calendar),
        Provider<ThemeRepository>.value(value: theme),
      ],
      child: const MaterialApp(
        home: EventsScreen(
          title: 'ZH-k',
          types: {EventType.midterm},
          eventLabel: 'zh',
        ),
      ),
    ));
    await tester.pumpAndSettle();
  }

  group('adatállapotok', () {
    testWidgets('az események listázva vannak, a figyelmeztetés látszik',
        (tester) async {
      events.getResult = Ok([
        event(id: 1, subject: analysis, location: 'A-101'),
        event(id: 2, subject: programming, location: 'B-202'),
      ]);

      await pump(tester);

      expect(find.text('ZH-k'), findsOneWidget);
      expect(find.byType(EventListCard), findsNWidgets(2));
      expect(find.text('Analízis I.'), findsOneWidget);
      expect(find.text('Programozás alapjai'), findsOneWidget);
      expect(find.text(_disclaimer), findsOneWidget);
    });

    testWidgets('a betöltés a megadott típusokkal kér', (tester) async {
      await pump(tester);

      expect(events.getCalls.first.types, {EventType.midterm});
      expect(events.getCalls.first.forceReload, isFalse);
    });

    testWidgets('üres lista: üres állapot, figyelmeztetés nincs',
        (tester) async {
      await pump(tester);

      expect(find.text('Nincs közelgő zh.'), findsOneWidget);
      expect(find.text(_disclaimer), findsNothing);
    });

    testWidgets('betöltési hiba: üzenet és Újra gomb, ami újratölt',
        (tester) async {
      events.getResult = const Err('Nem érhető el a szerver.');
      await pump(tester);

      expect(find.text('Nem érhető el a szerver.'), findsOneWidget);

      events.getResult = Ok([event(id: 1, location: 'A-101')]);
      await tester.tap(find.text('Újra'));
      await tester.pumpAndSettle();

      expect(events.getCalls.last.forceReload, isTrue);
      expect(find.text('Nem érhető el a szerver.'), findsNothing);
      expect(find.text('Analízis I.'), findsOneWidget);
    });

    testWidgets('a keresés tárgy nevére szűr, találat nélkül üzenet jön',
        (tester) async {
      events.getResult = Ok([
        event(id: 1, subject: analysis),
        event(id: 2, subject: programming),
      ]);
      await pump(tester);

      await tester.enterText(find.byType(TextField), 'programozás');
      await tester.pumpAndSettle();
      expect(find.text('Analízis I.'), findsNothing);
      expect(find.text('Programozás alapjai'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'xyz');
      await tester.pumpAndSettle();
      expect(find.byType(EventListCard), findsNothing);
      expect(find.textContaining('Nincs találat erre'), findsOneWidget);
    });
  });

  group('offline szalag', () {
    testWidgets('offlineSince esetén látszik', (tester) async {
      events.offlineSince = DateTime(2026, 11, 10, 9, 30);
      events.getResult = Ok([event(id: 1)]);

      await pump(tester);

      expect(find.byType(OfflineBanner), findsOneWidget);
      expect(find.textContaining('Offline.'), findsOneWidget);
    });

    testWidgets('online állapotban nincs', (tester) async {
      events.getResult = Ok([event(id: 1)]);

      await pump(tester);

      expect(find.byType(OfflineBanner), findsNothing);
    });
  });

  group('jogosultság', () {
    testWidgets('sima felhasználónak nincs felvétel gomb és törlés',
        (tester) async {
      events.getResult = Ok([event(id: 1)]);

      await pump(tester);

      expect(find.byIcon(Icons.add_rounded), findsNothing);
      expect(find.byType(Dismissible), findsNothing);
    });

    testWidgets('moderátornak a fejlécben van a felvétel gomb',
        (tester) async {
      auth.cachedUser = user(canModerateMidterms: true);

      await pump(tester);

      expect(find.byIcon(Icons.add_rounded), findsOneWidget);
      expect(
          tester.widget<EventsHeader>(find.byType(EventsHeader)).canModerate,
          isTrue);
      expect(
          tester.widget<Scaffold>(find.byType(Scaffold)).floatingActionButton,
          isNull);
    });

    testWidgets('moderátornak FAB módban a gomb lebeg, a fejlécben nincs',
        (tester) async {
      auth.cachedUser = user(canModerateMidterms: true);

      await pump(tester, asFab: true);

      expect(find.byIcon(Icons.add_rounded), findsOneWidget);
      expect(
          tester.widget<EventsHeader>(find.byType(EventsHeader)).canModerate,
          isFalse);
      expect(
          tester.widget<Scaffold>(find.byType(Scaffold)).floatingActionButton,
          isNotNull);
    });
  });

  group('felvétel', () {
    testWidgets('a felvétel gomb megnyitja az űrlapot, bezárás után újratölt',
        (tester) async {
      auth.cachedUser = user(canModerateMidterms: true);
      await pump(tester);
      final loadsBefore = events.getCalls.length;

      await tester.tap(find.byIcon(Icons.add_rounded));
      await tester.pumpAndSettle();
      expect(find.text('Új zh'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      expect(find.text('Új zh'), findsNothing);
      expect(events.getCalls.length, loadsBefore + 1);
      expect(events.getCalls.last.forceReload, isTrue);
    });
  });

  group('törlés', () {
    setUp(() => auth.cachedUser = user(canModerateMidterms: true));

    testWidgets('megerősítés után a repository-t hívja, az elem eltűnik',
        (tester) async {
      events.getResult = Ok([
        event(id: 1, subject: analysis),
        event(id: 2, subject: programming),
      ]);
      await pump(tester);

      await tester.drag(find.text('Programozás alapjai'), const Offset(-600, 0));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Törlés'));
      await tester.pumpAndSettle();

      expect(events.deletedIds, [2]);
      expect(find.text('Programozás alapjai'), findsNothing);
      expect(find.text('Analízis I.'), findsOneWidget);
    });

    testWidgets('sikertelen törlésnél hibaüzenet jön és az elem visszatér',
        (tester) async {
      events.getResult = Ok([event(id: 1, subject: analysis)]);
      events.deleteResult = const Err('Nem sikerült törölni.');
      await pump(tester);

      await tester.drag(find.text('Analízis I.'), const Offset(-600, 0));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Törlés'));
      await tester.pumpAndSettle();

      expect(find.text('Nem sikerült törölni.'), findsOneWidget);
      expect(find.text('Analízis I.'), findsOneWidget);
    });
  });
}
