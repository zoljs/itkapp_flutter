import 'package:flutter_test/flutter_test.dart';
import 'package:itk_app/data/repositories/calendar_repository.dart';
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
  late CalendarRepository repository;

  setUp(() {
    api = TestApiClient();
    repository = CalendarRepository(apiClient: api);
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
}
