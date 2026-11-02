import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:itk_app/data/repositories/wiki_sites_repository.dart';
import 'package:itk_app/domain/models/user_site.dart';
import 'package:itk_app/utils/result.dart';

import '../../helpers/fake_http.dart';

const _site = {
  'name': 'Teszt Elek',
  'url': 'https://users.itk.ppke.hu/~perpa4',
  'tags': ['Analizis'],
  'isPublic': true,
};

/// What the backend sends when the user has no site: `return site ?? null` -> 204, empty body.
ResponseBody _noContent() => ResponseBody.fromString('', 204);

void main() {
  late TestApiClient api;
  late WikiSitesRepository repository;

  /// Number of GET /api/sites/me requests sent so far.
  int mySiteRequests() => api.adapter.requests.where((r) => r.method == 'GET' && r.path == '/api/sites/me').length;

  setUp(() {
    api = TestApiClient();
    repository = WikiSitesRepository(apiClient: api);
  });

  group('get (saját oldal)', () {
    test('a második hívás a cache-ből jön', () async {
      api.adapter.handler = (_) => jsonBody(200, _site);

      final first = await repository.get();
      final second = await repository.get();

      expect(mySiteRequests(), 1);
      expect(first, isA<Ok<UserSite?>>().having((r) => r.value?.name, 'name', 'Teszt Elek'));
      expect(second, isA<Ok<UserSite?>>().having((r) => r.value?.name, 'name', 'Teszt Elek'));
    });

    test('nincs oldal (204, üres válasz): Ok(null), és ez is a cache-be kerül', () async {
      api.adapter.handler = (_) => _noContent();

      final first = await repository.get();
      final second = await repository.get();

      expect(first, isA<Ok<UserSite?>>().having((r) => r.value, 'value', isNull));
      expect(second, isA<Ok<UserSite?>>().having((r) => r.value, 'value', isNull));
      expect(mySiteRequests(), 1);
    });

    test('forceReload újra kér', () async {
      api.adapter.handler = (_) => jsonBody(200, _site);

      await repository.get();
      await repository.get(forceReload: true);

      expect(mySiteRequests(), 2);
    });

    test('a hiba nem kerül a cache-be', () async {
      api.adapter.handler = (_) => jsonBody(500, null);
      expect(await repository.get(), isA<Err<UserSite?>>());

      api.adapter.handler = (_) => jsonBody(200, _site);
      expect(await repository.get(), isA<Ok<UserSite?>>());
      expect(mySiteRequests(), 2);
    });

    test('értelmetlen válasz (nem objektum) Err, nem Ok(null)', () async {
      api.adapter.handler = (_) => jsonBody(200, 42);

      expect(await repository.get(), isA<Err<UserSite?>>());
    });
  });

  group('mutációk', () {
    test('save után a get a mentett oldalt adja, kérés nélkül', () async {
      api.adapter.handler = (_) => _noContent();
      await repository.get();

      api.adapter.handler = (_) => jsonBody(200, _site);
      await repository.save(['Analizis'], true);
      final result = await repository.get();

      expect(mySiteRequests(), 1);
      expect(result, isA<Ok<UserSite?>>().having((r) => r.value?.name, 'name', 'Teszt Elek'));
    });

    test('save után az oldalak listáját újra kéri', () async {
      api.adapter.handler = (_) => jsonBody(200, [_site]);
      await repository.getAll();

      api.adapter.handler = (_) => jsonBody(200, _site);
      await repository.save(['Analizis'], true);

      api.adapter.handler = (_) => jsonBody(200, [_site]);
      await repository.getAll();

      final listRequests = api.adapter.requests.where((r) => r.method == 'GET' && r.path == '/api/sites').length;
      expect(listRequests, 2);
    });

    test('delete után a get Ok(null)-t ad, kérés nélkül', () async {
      api.adapter.handler = (_) => jsonBody(200, _site);
      await repository.get();

      api.adapter.handler = (_) => jsonBody(200, null);
      await repository.delete();
      final result = await repository.get();

      expect(mySiteRequests(), 1);
      expect(result, isA<Ok<UserSite?>>().having((r) => r.value, 'value', isNull));
    });

    test('clearCache (kijelentkezés) után újra kér', () async {
      api.adapter.handler = (_) => jsonBody(200, _site);
      await repository.get();

      repository.clearCache();
      await repository.get();

      expect(mySiteRequests(), 2);
    });
  });
}
