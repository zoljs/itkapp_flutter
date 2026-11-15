import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:itk_app/data/repositories/absolutorium_repository.dart';
import 'package:itk_app/data/repositories/auth_repository.dart';
import 'package:itk_app/data/repositories/calendar_repository.dart';
import 'package:itk_app/data/repositories/event_repository.dart';
import 'package:itk_app/data/repositories/hint_repository.dart';
import 'package:itk_app/data/repositories/onboarding_repository.dart';
import 'package:itk_app/data/repositories/subjects_repository.dart';
import 'package:itk_app/data/repositories/theme_repository.dart';
import 'package:itk_app/data/repositories/wiki_sites_repository.dart';
import 'package:itk_app/data/services/api_client.dart';
import 'package:itk_app/data/services/offline_store.dart';
import 'package:itk_app/data/services/shared_preferences_service.dart';
import 'package:itk_app/domain/models/user.dart';
import 'package:itk_app/routing/routes.dart';
import 'package:itk_app/ui/core/widgets/grouped_list.dart';
import 'package:itk_app/ui/settings/settings_screen.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/fake_http.dart';
import '../../helpers/fake_repositories.dart';
import '../../helpers/fixtures.dart';

class _FakeOfflineStore implements OfflineStore {
  int clearCount = 0;

  @override
  Future<void> clear() async => clearCount++;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

const _admin = LdapUser(
  id: 2,
  login: 'admin1',
  name: 'Admin Aladár',
  givenName: 'Aladár',
  familyName: 'Admin',
  isAdmin: true,
);

GoRoute _stub(String path) => GoRoute(
      path: path,
      builder: (_, __) => Scaffold(body: Center(child: Text('oldal: $path'))),
    );

void main() {
  late SharedPreferences rawPrefs;
  late FakeAuthRepository auth;
  late ThemeRepository theme;
  late OnboardingRepository onboarding;
  late _FakeOfflineStore offlineStore;
  late FakeSubjectsRepository subjects;
  late FakeSitesRepository sites;
  late FakeCalendarRepository calendar;
  late FakeAbsolutoriumRepository absolutorium;
  late FakeEventRepository events;

  setUp(() {
    PackageInfo.setMockInitialValues(
      appName: 'itk_app',
      packageName: 'hu.test.itkapp',
      version: '1.2.3',
      buildNumber: '45',
      buildSignature: '',
    );
    auth = FakeAuthRepository()..cachedUser = user();
    offlineStore = _FakeOfflineStore();
    subjects = FakeSubjectsRepository();
    sites = FakeSitesRepository();
    calendar = FakeCalendarRepository();
    absolutorium = FakeAbsolutoriumRepository();
    events = FakeEventRepository();
  });

  Future<void> pump(WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({
      'hasSeenOnboarding': true,
      'hintful.home': 'true',
    });
    rawPrefs = await SharedPreferences.getInstance();
    final prefs = SharedPreferencesService(rawPrefs);
    theme = ThemeRepository(prefs: prefs);
    onboarding = OnboardingRepository(prefs: prefs);

    final router = GoRouter(
      initialLocation: Routes.settings,
      routes: [
        GoRoute(
            path: Routes.settings, builder: (_, __) => const SettingsScreen()),
        _stub(Routes.calendarLinks),
        _stub(Routes.adminRoles),
      ],
    );
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthRepository>.value(value: auth),
        Provider<ThemeRepository>.value(value: theme),
        Provider<ApiClient>.value(value: TestApiClient()),
        Provider<OnboardingRepository>.value(value: onboarding),
        Provider<HintRepository>.value(value: HintRepository(prefs: prefs)),
        Provider<OfflineStore>.value(value: offlineStore),
        Provider<SubjectsRepository>.value(value: subjects),
        Provider<WikiSitesRepository>.value(value: sites),
        ChangeNotifierProvider<CalendarRepository>.value(value: calendar),
        Provider<AbsolutoriumRepository>.value(value: absolutorium),
        Provider<EventRepository>.value(value: events),
      ],
      child: MaterialApp.router(routerConfig: router),
    ));
    await tester.pumpAndSettle();
  }

  Future<void> tapTile(WidgetTester tester, String title) async {
    final tile = find.widgetWithText(SettingsTile, title);
    await tester.scrollUntilVisible(tile, 300);
    await tester.pumpAndSettle();
    await tester.tap(tile);
    await tester.pumpAndSettle();
  }

  group('megjelenés', () {
    testWidgets('a fiók adatai és a verzió látszanak', (tester) async {
      await pump(tester);

      expect(find.text('Beállítások'), findsOneWidget);
      expect(find.text('Fiók'), findsOneWidget);
      expect(find.text('Teszt Elek'), findsOneWidget);
      expect(find.text('perpa4'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);

      await tester.scrollUntilVisible(find.text('Verzió'), 300);
      expect(find.text('1.2.3 (45)'), findsOneWidget);
    });

    testWidgets('nincs bejelentkezett felhasználó: nincs Fiók csoport',
        (tester) async {
      auth.cachedUser = null;

      await pump(tester);

      expect(find.text('Fiók'), findsNothing);
    });

    testWidgets('az Adminisztrátor csoport csak adminnak látszik',
        (tester) async {
      await pump(tester);
      expect(find.text('Adminisztrátor'), findsNothing);
    });

    testWidgets('admin: a Jogosultságok sor a jogosultságok oldalra visz',
        (tester) async {
      auth.cachedUser = _admin;
      await pump(tester);

      await tapTile(tester, 'Jogosultságok');

      expect(find.text('oldal: ${Routes.adminRoles}'), findsOneWidget);
    });

    testWidgets('a Naptárlinkek sor a naptárlinkek oldalra visz',
        (tester) async {
      await pump(tester);

      await tapTile(tester, 'Naptárlinkek');

      expect(find.text('oldal: ${Routes.calendarLinks}'), findsOneWidget);
    });
  });

  group('kapcsolók', () {
    testWidgets('az OLED mód sorra koppintva átvált és elmenti',
        (tester) async {
      await pump(tester);
      expect(theme.oledMode.value, isFalse);

      await tapTile(tester, 'OLED mód');

      expect(theme.oledMode.value, isTrue);
      expect(rawPrefs.getBool('oledMode'), isTrue);

      await tapTile(tester, 'OLED mód');
      expect(theme.oledMode.value, isFalse);
    });

    testWidgets('az Akció gombok lent sorra koppintva átvált és elmenti',
        (tester) async {
      await pump(tester);
      expect(theme.actionButtonAsFab.value, isFalse);

      await tapTile(tester, 'Akció gombok lent');

      expect(theme.actionButtonAsFab.value, isTrue);
      expect(rawPrefs.getBool('actionButtonAsFab'), isTrue);
    });
  });

  group('debug műveletek', () {
    testWidgets('a gyorsítótár törlése minden repository-t ürít',
        (tester) async {
      await pump(tester);

      await tapTile(tester, 'Gyorsítótár törlése');

      expect(subjects.clearCount, 1);
      expect(sites.clearCount, 1);
      expect(calendar.clearCount, 1);
      expect(absolutorium.clearCount, 1);
      expect(events.clearCount, 1);
      expect(find.text('Gyorsítótárak törölve!'), findsOneWidget);
    });

    testWidgets('a munkamenet törlése üzenetet ad', (tester) async {
      await pump(tester);

      await tapTile(tester, 'Munkamenet törlése');

      expect(find.text('Cookie törölve, most frissíts valamit.'),
          findsOneWidget);
    });

    testWidgets('az onboarding visszaállítása törli a jelzőt és a hinteket',
        (tester) async {
      await pump(tester);
      expect(onboarding.hasSeenOnboarding.value, isTrue);

      await tapTile(tester, 'Onboarding visszaállítása');

      expect(onboarding.hasSeenOnboarding.value, isFalse);
      expect(rawPrefs.containsKey('hasSeenOnboarding'), isFalse);
      expect(rawPrefs.containsKey('hintful.home'), isFalse);
      expect(find.text('Onboarding visszaállítva.'), findsOneWidget);
    });
  });

  group('kijelentkezés', () {
    Future<void> tapLogout(WidgetTester tester) async {
      final button = find.widgetWithText(InkWell, 'Kijelentkezés');
      await tester.scrollUntilVisible(button, 300);
      await tester.pumpAndSettle();
      await tester.tap(button);
      await tester.pumpAndSettle();
    }

    testWidgets('megerősítés után törli az adatokat és kijelentkeztet',
        (tester) async {
      await pump(tester);

      await tapLogout(tester);
      expect(find.text('Kijelentkezel?'), findsOneWidget);
      expect(auth.logoutCount, 0);

      await tester.tap(find.widgetWithText(FilledButton, 'Kijelentkezés'));
      await tester.pumpAndSettle();

      expect(auth.logoutCount, 1);
      expect(offlineStore.clearCount, 1);
      expect(subjects.clearCount, 1);
      expect(sites.clearCount, 1);
      expect(calendar.clearCount, 1);
      expect(absolutorium.clearCount, 1);
      expect(events.clearCount, 1);
    });

    testWidgets('mégse: semmi nem törlődik', (tester) async {
      await pump(tester);

      await tapLogout(tester);
      await tester.tap(find.text('Mégse'));
      await tester.pumpAndSettle();

      expect(auth.logoutCount, 0);
      expect(offlineStore.clearCount, 0);
      expect(auth.isAuthenticated, isTrue);
    });
  });
}
