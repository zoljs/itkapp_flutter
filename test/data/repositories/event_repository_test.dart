import 'package:flutter_test/flutter_test.dart';
import 'package:itk_app/data/repositories/event_repository.dart';
import 'package:itk_app/domain/models/event.dart';
import 'package:itk_app/utils/result.dart';

import '../../helpers/fake_http.dart';

Map<String, dynamic> eventJson(int id, String type) => {
      'id': id,
      'type': type,
      'startsAt': '2026-11-03T10:00:00.000Z',
      'subject': {'id': 1, 'code': 'ITK101', 'name': 'Analízis I.'},
    };

void main() {
  late TestApiClient api;
  late EventRepository repository;

  setUp(() {
    api = TestApiClient();
    api.adapter.handler = (_) => jsonBody(200, [eventJson(1, 'MIDTERM')]);
    repository = EventRepository(apiClient: api);
  });

  group('get', () {
    test('a típusokat rendezve, vesszővel küldi', () async {
      await repository.get(types: {EventType.retake, EventType.midterm});

      expect(api.adapter.last.path, '/api/midterms');
      expect(api.adapter.last.queryParameters['type'], 'MIDTERM,RETAKE');
    });

    test('ugyanaz a halmaz más sorrendben ugyanazt a cache-t használja', () async {
      await repository.get(types: {EventType.midterm, EventType.retake});
      await repository.get(types: {EventType.retake, EventType.midterm});

      expect(api.adapter.requests, hasLength(1));
    });

    test('más típusok külön kérés és külön cache', () async {
      await repository.get(types: {EventType.midterm, EventType.retake});
      await repository.get(types: {EventType.consultation});

      expect(api.adapter.requests, hasLength(2));
      expect(api.adapter.last.queryParameters['type'], 'CONSULTATION');
    });

    test('forceReload újra letölti', () async {
      await repository.get(types: {EventType.consultation});
      await repository.get(types: {EventType.consultation}, forceReload: true);

      expect(api.adapter.requests, hasLength(2));
    });

    test('hibás válasz nem kerül a cache-be', () async {
      api.adapter.handler = (_) => jsonBody(500, null);
      final failed = await repository.get(types: {EventType.midterm});
      expect(failed, isA<Err<List<Event>>>());

      api.adapter.handler = (_) => jsonBody(200, [eventJson(1, 'MIDTERM')]);
      final ok = await repository.get(types: {EventType.midterm});
      expect(ok, isA<Ok<List<Event>>>());
      expect(api.adapter.requests, hasLength(2));
    });
  });

  group('add', () {
    test('a típust és az UTC időt küldi, üres helyszín nélkül', () async {
      await repository.add(
        subjectId: 1,
        startsAt: DateTime.utc(2026, 11, 3, 10),
        type: EventType.consultation,
      );

      final body = api.adapter.last.data as Map<String, dynamic>;
      expect(api.adapter.last.method, 'POST');
      expect(body['subjectId'], 1);
      expect(body['type'], 'CONSULTATION');
      expect(body['startsAt'], '2026-11-03T10:00:00.000Z');
      expect(body.containsKey('location'), isFalse);
    });

    test('sikeres felvétel után üríti a cache-t', () async {
      await repository.get(types: {EventType.midterm});
      await repository.add(subjectId: 1, startsAt: DateTime.utc(2026), type: EventType.midterm);
      await repository.get(types: {EventType.midterm});

      // get, add, get again because the cache was cleared
      expect(api.adapter.requests, hasLength(3));
    });
  });

  test('delete a címben küldi az id-t', () async {
    await repository.delete(id: 42);

    expect(api.adapter.last.method, 'DELETE');
    expect(api.adapter.last.path, '/api/midterms/42');
  });
}
