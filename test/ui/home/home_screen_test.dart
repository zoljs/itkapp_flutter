import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:itk_app/data/repositories/absolutorium_repository.dart';
import 'package:itk_app/data/repositories/auth_repository.dart';
import 'package:itk_app/data/repositories/calendar_repository.dart';
import 'package:itk_app/domain/models/calendar_event.dart';
import 'package:itk_app/routing/routes.dart';
import 'package:itk_app/ui/core/widgets/settings_avatar_button.dart';
import 'package:itk_app/ui/home/home_screen.dart';
import 'package:itk_app/ui/home/widgets/next_class_card.dart';
import 'package:itk_app/utils/result.dart';
import 'package:provider/provider.dart';

import '../../helpers/fake_repositories.dart';
import '../../helpers/fixtures.dart';
import '../../helpers/hintful.dart';

/// A stub page per route, so a push can be seen as text.
GoRoute _stub(String path) => GoRoute(
      path: path,
      builder: (_, __) => Scaffold(body: Center(child: Text('oldal: $path'))),
    );

Widget _app({
  required FakeAuthRepository auth,
  required FakeCalendarRepository calendar,
}) {
  final router = GoRouter(
    initialLocation: Routes.home,
    routes: [
      GoRoute(path: Routes.home, builder: (_, __) => const HomeScreen()),
      _stub(Routes.settings),
      _stub(Routes.midterms),
      _stub(Routes.consultations),
      _stub(Routes.absolutorium),
      _stub(Routes.videos),
    ],
  );
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<AuthRepository>.value(value: auth),
      ChangeNotifierProvider<CalendarRepository>.value(value: calendar),
      Provider<AbsolutoriumRepository>.value(
          value: FakeAbsolutoriumRepository()),
    ],
    child: MaterialApp.router(routerConfig: router),
  );
}

CalendarEvent _upcoming(String title, {String? location}) {
  final start = DateTime.now().add(const Duration(days: 1));
  return CalendarEvent(
    title: title,
    start: start,
    end: start.add(const Duration(hours: 1)),
    location: location,
  );
}

void main() {
  setUpAll(() => initializeDateFormatting('hu'));

  late FakeAuthRepository auth;
  late FakeCalendarRepository calendar;

  setUp(() {
    silenceHintTours();
    auth = FakeAuthRepository()..cachedUser = user();
    calendar = FakeCalendarRepository();
  });

  Future<void> pump(WidgetTester tester) async {
    await tester.pumpWidget(_app(auth: auth, calendar: calendar));
    await tester.pumpAndSettle();
  }

  testWidgets('köszöntés a felhasználó keresztnevével, a szekciók látszanak',
      (tester) async {
    await pump(tester);

    expect(find.textContaining('Elek!'), findsOneWidget);
    expect(find.text('Következő óra'), findsOneWidget);
    expect(find.text('Időpontok'), findsOneWidget);
    expect(find.text('Zárthelyi dolgozatok'), findsOneWidget);
    expect(find.text('Konzultációk'), findsOneWidget);
  });

  testWidgets('nincs bejelentkezett felhasználó: diák', (tester) async {
    auth.cachedUser = null;

    await pump(tester);

    expect(find.textContaining('diák!'), findsOneWidget);
  });

  testWidgets('van közelgő óra: a kártya a címet és a helyszínt mutatja',
      (tester) async {
    calendar.getResult =
        Ok([_upcoming('Analízis I. (gyakorlat)', location: '318')]);

    await pump(tester);

    expect(find.byType(NextClassCard), findsOneWidget);
    expect(find.text('Analízis I. (gyakorlat)'), findsOneWidget);
    expect(find.textContaining('318'), findsOneWidget);
    expect(find.text('Nincs közelgő órád.'), findsNothing);
  });

  testWidgets('a legkorábbi közelgő óra a következő', (tester) async {
    final soon = DateTime.now().add(const Duration(hours: 2));
    calendar.getResult = Ok([
      _upcoming('Holnapi óra'),
      CalendarEvent(
        title: 'Hamarabbi óra',
        start: soon,
        end: soon.add(const Duration(hours: 1)),
      ),
    ]);

    await pump(tester);

    expect(find.text('Hamarabbi óra'), findsOneWidget);
    expect(find.text('Holnapi óra'), findsNothing);
  });

  testWidgets('nincs közelgő óra: üres állapot', (tester) async {
    await pump(tester);

    expect(find.text('Nincs közelgő órád.'), findsOneWidget);
    expect(find.byType(NextClassCard), findsNothing);
  });

  testWidgets('betöltési hiba: üzenet és Újra gomb, ami újra próbálja',
      (tester) async {
    calendar.getResult = const Err('Nem érhető el a szerver.');
    await pump(tester);

    expect(find.text('Nem érhető el a szerver.'), findsOneWidget);

    calendar.getResult = Ok([_upcoming('Analízis I. (gyakorlat)')]);
    await tester.tap(find.text('Újra'));
    await tester.pumpAndSettle();

    expect(find.text('Nem érhető el a szerver.'), findsNothing);
    expect(find.text('Analízis I. (gyakorlat)'), findsOneWidget);
  });

  group('navigáció', () {
    testWidgets('az avatar a beállításokra visz', (tester) async {
      await pump(tester);

      await tester.tap(find.byType(SettingsAvatarButton));
      await tester.pumpAndSettle();

      expect(find.text('oldal: ${Routes.settings}'), findsOneWidget);
    });

    final tiles = {
      'Zárthelyi dolgozatok': Routes.midterms,
      'Konzultációk': Routes.consultations,
      'Abszolutórium': Routes.absolutorium,
      'Online Videók': Routes.videos,
    };
    for (final entry in tiles.entries) {
      testWidgets('${entry.key} -> ${entry.value}', (tester) async {
        tester.view.devicePixelRatio = 1.0;
        tester.view.physicalSize = const Size(800, 2400);
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await pump(tester);
        await tester.pumpAndSettle();
        await tester.tap(find.text(entry.key));
        await tester.pumpAndSettle();

        expect(find.text('oldal: ${entry.value}'), findsOneWidget);
      });
    }
  });
}
