import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:itk_app/data/repositories/absolutorium_repository.dart';
import 'package:itk_app/data/repositories/auth_repository.dart';
import 'package:itk_app/data/repositories/calendar_repository.dart';
import 'package:itk_app/data/repositories/event_repository.dart';
import 'package:itk_app/data/repositories/subjects_repository.dart';
import 'package:itk_app/data/repositories/wiki_sites_repository.dart';
import 'package:itk_app/data/services/offline_store.dart';
import 'package:itk_app/ui/core/navigator_key.dart';
import 'package:itk_app/utils/auth_actions.dart';
import 'package:provider/provider.dart';

import '../helpers/fake_repositories.dart';
import '../helpers/fixtures.dart';

void main() {
  late Directory root;
  late OfflineStore store;
  late FakeAuthRepository auth;
  late FakeSubjectsRepository subjects;
  late FakeSitesRepository sites;
  late FakeCalendarRepository calendar;
  late FakeAbsolutoriumRepository absolutorium;
  late FakeEventRepository events;

  setUp(() async {
    root = await Directory.systemTemp.createTemp('auth_actions_test');
    store =
        OfflineStore(directory: () async => Directory('${root.path}/offline'));
    auth = FakeAuthRepository()..cachedUser = user();
    subjects = FakeSubjectsRepository();
    sites = FakeSitesRepository();
    calendar = FakeCalendarRepository();
    absolutorium = FakeAbsolutoriumRepository();
    events = FakeEventRepository();
  });

  tearDown(() async {
    if (await root.exists()) await root.delete(recursive: true);
  });

  Widget providers({required Widget child}) => MultiProvider(
        providers: [
          Provider<OfflineStore>.value(value: store),
          ChangeNotifierProvider<AuthRepository>.value(value: auth),
          Provider<SubjectsRepository>.value(value: subjects),
          Provider<WikiSitesRepository>.value(value: sites),
          ChangeNotifierProvider<CalendarRepository>.value(value: calendar),
          Provider<AbsolutoriumRepository>.value(value: absolutorium),
          Provider<EventRepository>.value(value: events),
        ],
        child: child,
      );

  Future<void> seedOfflineStore() async {
    await store.write('calendar', 'BEGIN:VCALENDAR');
    await store.write('events_MIDTERM', <Object>[]);
  }

  void expectAllCleared() {
    expect(subjects.clearCount, 1);
    expect(sites.clearCount, 1);
    expect(calendar.clearCount, 1);
    expect(absolutorium.clearCount, 1);
    expect(events.clearCount, 1);
    expect(auth.logoutCount, 1);
  }

  group('performLogout', () {
    testWidgets('törli a gyorsítótárakat, az offline tárat és kijelentkeztet',
        (tester) async {
      late BuildContext context;
      await tester.pumpWidget(providers(
        child: MaterialApp(
          home: Builder(builder: (c) {
            context = c;
            return const SizedBox();
          }),
        ),
      ));

      await tester.runAsync(() async {
        await seedOfflineStore();
        expect(await store.read('calendar'), isNotNull);

        await performLogout(context);

        expect(await store.read('calendar'), isNull);
        expect(await store.read('events_MIDTERM'), isNull);
      });

      expectAllCleared();
      expect(auth.isAuthenticated, isFalse);
    });
  });

  group('handleSessionExpired', () {
    testWidgets('nincs navigátor: nem csinál semmit', (tester) async {
      await handleSessionExpired();

      expect(auth.logoutCount, 0);
      expect(subjects.clearCount, 0);
    });

    testWidgets('üzenetet mutat, majd mindent töröl és kijelentkeztet',
        (tester) async {
      await tester.pumpWidget(providers(
        child: MaterialApp(
          navigatorKey: navigatorKey,
          home: const Scaffold(body: SizedBox()),
        ),
      ));

      await tester.runAsync(() async {
        await seedOfflineStore();

        await handleSessionExpired();

        expect(await store.read('calendar'), isNull);
        expect(await store.read('events_MIDTERM'), isNull);
      });
      await tester.pump();

      expect(find.text('A munkameneted lejárt, jelentkezz be újra.'),
          findsOneWidget);
      expectAllCleared();
      expect(auth.isAuthenticated, isFalse);
    });
  });
}
