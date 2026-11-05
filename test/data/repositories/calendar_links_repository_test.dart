import 'package:flutter_test/flutter_test.dart';
import 'package:itk_app/data/repositories/calendar_links_repository.dart';
import 'package:itk_app/domain/models/calendar_link.dart';
import 'package:itk_app/utils/result.dart';

import '../../helpers/fake_http.dart';

void main() {
  late TestApiClient api;
  late CalendarLinksRepository repository;

  setUp(() {
    api = TestApiClient();
    repository = CalendarLinksRepository(apiClient: api);
  });

  test('get a v2 végpontról tölt', () async {
    api.adapter.handler = (_) => jsonBody(200, [
          {
            'id': 1,
            'name': 'Neptun',
            'url': 'https://n/c.ics',
            'syncInterval': '1d',
            'lastSyncedAt': null,
            'lastError': null
          },
        ]);

    final result = await repository.get();

    expect(api.adapter.last.path, '/api/calendar/v2/links');
    expect(
        result,
        isA<Ok<List<CalendarLink>>>()
            .having((r) => r.value.single.name, 'name', 'Neptun'));
  });

  test('add a gyakoriság szerver értékét küldi', () async {
    api.adapter.handler = (_) => jsonBody(201, null);

    await repository.add(
        name: 'Edzés',
        url: 'webcal://x/c.ics',
        syncInterval: SyncInterval.sixHours);

    final body = api.adapter.last.data as Map<String, dynamic>;
    expect(api.adapter.last.method, 'POST');
    expect(body,
        {'name': 'Edzés', 'url': 'webcal://x/c.ics', 'syncInterval': '6h'});
  });

  test('duplikált link: a 409 magyar üzenet', () async {
    api.adapter.handler = (_) => jsonBody(409, {
          'data': {'code': 'DUPLICATE_LINK'},
        });

    final result = await repository.add(
        name: 'x', url: 'https://x', syncInterval: SyncInterval.daily);

    expect(
        result,
        isA<Err<void>>().having(
            (r) => r.message, 'message', 'Ez a link már fel van véve.'));
  });

  test('delete a címben küldi az id-t', () async {
    api.adapter.handler = (_) => jsonBody(200, {'id': 5});

    await repository.delete(id: 5);

    expect(api.adapter.last.method, 'DELETE');
    expect(api.adapter.last.path, '/api/calendar/v2/links/5');
  });
}
