import 'package:flutter_test/flutter_test.dart';
import 'package:itk_app/data/repositories/subjects_repository.dart';
import 'package:itk_app/domain/models/subject.dart';
import 'package:itk_app/utils/result.dart';

import '../../helpers/fake_http.dart';

const _subjects = [
  {'id': 1, 'code': 'ITK101', 'name': 'Analízis I.'},
  {'id': 2, 'code': 'ITK202', 'name': 'Programozás alapjai'},
];

void main() {
  late TestApiClient api;
  late SubjectsRepository repository;

  int requests() => api.adapter.requests.length;

  setUp(() {
    api = TestApiClient();
    repository = SubjectsRepository(apiClient: api);
  });

  test('get a /api/subjects végpontról tölt és parse-ol', () async {
    api.adapter.handler = (_) => jsonBody(200, _subjects);

    final result = await repository.get();

    expect(api.adapter.last.path, '/api/subjects');
    expect(
        result,
        isA<Ok<List<Subject>>>()
            .having((r) => r.value.map((s) => s.code).toList(), 'kódok',
                ['ITK101', 'ITK202']));
  });

  test('a második hívás a cache-ből jön, forceReload újra kér', () async {
    api.adapter.handler = (_) => jsonBody(200, _subjects);

    await repository.get();
    await repository.get();
    expect(requests(), 1);

    await repository.get(forceReload: true);
    expect(requests(), 2);
  });

  test('clearCache után újra kér', () async {
    api.adapter.handler = (_) => jsonBody(200, _subjects);
    await repository.get();

    repository.clearCache();
    await repository.get();

    expect(requests(), 2);
  });

  test('a hiba nem kerül a cache-be', () async {
    api.adapter.handler = (_) => jsonBody(500, null);
    expect(await repository.get(), isA<Err<List<Subject>>>());

    api.adapter.handler = (_) => jsonBody(200, _subjects);
    expect(await repository.get(), isA<Ok<List<Subject>>>());
    expect(requests(), 2);
  });

  test('hibás tárgy (hiányzó név): Err, nem dob', () async {
    api.adapter.handler = (_) => jsonBody(200, [
          {'id': 1, 'code': 'ITK101'},
        ]);

    expect(await repository.get(), isA<Err<List<Subject>>>());
  });
}
