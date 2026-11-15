import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:itk_app/data/services/offline_store.dart';

void main() {
  late Directory root;
  late OfflineStore store;

  setUp(() async {
    root = await Directory.systemTemp.createTemp('offline_store_test');
    store =
        OfflineStore(directory: () async => Directory('${root.path}/offline'));
  });

  tearDown(() async {
    if (await root.exists()) await root.delete(recursive: true);
  });

  test('nincs mentés: null', () async {
    expect(await store.read('calendar'), isNull);
  });

  test('szöveget és mentési időt visszaad', () async {
    final now = DateTime.utc(2026, 11, 15, 12, 30);
    await store.write('calendar', 'BEGIN:VCALENDAR', now: now);

    final entry = await store.read('calendar');

    expect(entry?.data, 'BEGIN:VCALENDAR');
    expect(entry?.savedAt.toUtc(), now);
  });

  test('JSON listát visszaad, a kulcsok külön fájlok', () async {
    await store.write('events_MIDTERM', [
      {'id': 1}
    ]);
    await store.write('events_RETAKE', <Object>[]);

    expect((await store.read('events_MIDTERM'))?.data, [
      {'id': 1}
    ]);
    expect((await store.read('events_RETAKE'))?.data, isEmpty);
  });

  test('felülírja a régebbi mentést', () async {
    await store.write('calendar', 'old');
    await store.write('calendar', 'new');

    expect((await store.read('calendar'))?.data, 'new');
  });

  test('sérült fájl: null, nem dob', () async {
    final file = File('${root.path}/offline/calendar.json');
    await file.create(recursive: true);
    await file.writeAsString('{not json');

    expect(await store.read('calendar'), isNull);
  });

  test('hiányzó mentési idő: null', () async {
    final file = File('${root.path}/offline/calendar.json');
    await file.create(recursive: true);
    await file.writeAsString('{"data": "x"}');

    expect(await store.read('calendar'), isNull);
  });

  test('clear mindent töröl, utána újra írható', () async {
    await store.write('calendar', 'x');
    await store.write('events_MIDTERM', <Object>[]);

    await store.clear();

    expect(await store.read('calendar'), isNull);
    expect(await store.read('events_MIDTERM'), isNull);

    await store.write('calendar', 'y');
    expect((await store.read('calendar'))?.data, 'y');
  });

  test('clear üres tárolón sem dob', () async {
    await store.clear();
  });
}
