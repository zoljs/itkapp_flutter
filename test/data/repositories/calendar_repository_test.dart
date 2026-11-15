import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:itk_app/data/repositories/calendar_repository.dart';
import 'package:itk_app/data/services/offline_store.dart';
import 'package:itk_app/domain/models/calendar_event.dart';
import 'package:itk_app/utils/result.dart';

import '../../helpers/fake_http.dart';

const _ics = 'BEGIN:VCALENDAR\r\n'
    'VERSION:2.0\r\n'
    'PRODID:-//ITKApp//Test//EN\r\n'
    'BEGIN:VEVENT\r\n'
    'UID:1\r\n'
    'SUMMARY:Analízis\r\n'
    'DTSTART:20261103T080000Z\r\n'
    'END:VEVENT\r\n'
    'END:VCALENDAR';

void main() {
  late TestApiClient api;
  late Directory root;
  late OfflineStore store;
  late CalendarRepository repository;

  setUp(() async {
    api = TestApiClient();
    root = await Directory.systemTemp.createTemp('calendar_repository_test');
    store =
        OfflineStore(directory: () async => Directory('${root.path}/offline'));
    repository = CalendarRepository(apiClient: api, offlineStore: store);
  });

  tearDown(() async {
    if (await root.exists()) await root.delete(recursive: true);
  });

  test('beolvassa az ICS-t', () async {
    api.adapter.handler = (_) => textBody(200, _ics);

    final result = await repository.get();

    expect(
        result,
        isA<Ok<List<CalendarEvent>>>()
            .having((r) => r.value.single.title, 'title', 'Analízis'));
  });

  test('üres válasz üres naptár, nem hiba', () async {
    api.adapter.handler = (_) => textBody(200, '');

    final result = await repository.get();

    expect(
        result,
        isA<Ok<List<CalendarEvent>>>()
            .having((r) => r.value, 'value', isEmpty));
  });

  test('cache-el, a forceReload újratölt', () async {
    api.adapter.handler = (_) => textBody(200, _ics);

    await repository.get();
    await repository.get();
    expect(api.adapter.requests, hasLength(1));

    await repository.get(forceReload: true);
    expect(api.adapter.requests, hasLength(2));
  });

  test('a clearCache után újratölt', () async {
    api.adapter.handler = (_) => textBody(200, _ics);

    await repository.get();
    repository.clearCache();
    await repository.get();

    expect(api.adapter.requests, hasLength(2));
  });

  test('szerver hiba Err', () async {
    api.adapter.handler = (_) => jsonBody(500, null);

    expect(await repository.get(), isA<Err<List<CalendarEvent>>>());
  });

  group('offline fallback', () {
    final savedAt = DateTime.utc(2026, 11, 14, 18, 5);

    test('sikeres letöltés után elmenti a nyers választ', () async {
      api.adapter.handler = (_) => textBody(200, _ics);

      await repository.get();

      expect((await store.read('calendar'))?.data, _ics);
      expect(repository.offlineSince, isNull);
    });

    test('szerver hiba esetén a mentett naptárat adja, mentési idővel',
        () async {
      await store.write('calendar', _ics, now: savedAt);
      api.adapter.handler = (_) => jsonBody(500, null);

      final result = await repository.get();

      expect(
          result,
          isA<Ok<List<CalendarEvent>>>()
              .having((r) => r.value.single.title, 'title', 'Analízis'));
      expect(repository.offlineSince?.toUtc(), savedAt);
    });

    test('szerver hiba és nincs mentés: Err, offlineSince null', () async {
      api.adapter.handler = (_) => jsonBody(500, null);

      expect(await repository.get(), isA<Err<List<CalendarEvent>>>());
      expect(repository.offlineSince, isNull);
    });

    test('hibás mentés: az eredeti Err, offlineSince null', () async {
      await store.write('calendar', 'ez nem naptár', now: savedAt);
      api.adapter.handler = (_) => jsonBody(500, null);

      expect(await repository.get(), isA<Err<List<CalendarEvent>>>());
      expect(repository.offlineSince, isNull);
    });

    test('a mentett adat nem kerül a memória cache-be', () async {
      await store.write('calendar', _ics, now: savedAt);
      api.adapter.handler = (_) => jsonBody(500, null);

      await repository.get();
      await repository.get();

      expect(api.adapter.requests, hasLength(2));
    });

    test('újra sikeres letöltés után offlineSince null', () async {
      await store.write('calendar', _ics, now: savedAt);
      api.adapter.handler = (_) => jsonBody(500, null);
      await repository.get();
      expect(repository.offlineSince, isNotNull);

      api.adapter.handler = (_) => textBody(200, _ics);
      await repository.get(forceReload: true);

      expect(repository.offlineSince, isNull);
    });

    test('sikertelen fallback törli a korábbi offlineSince-t', () async {
      await store.write('calendar', _ics, now: savedAt);
      api.adapter.handler = (_) => jsonBody(500, null);
      await repository.get();

      await store.clear();
      await repository.get(forceReload: true);

      expect(repository.offlineSince, isNull);
    });
  });
}
