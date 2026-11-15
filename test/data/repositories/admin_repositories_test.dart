import 'package:flutter_test/flutter_test.dart';
import 'package:itk_app/data/repositories/admin/admin_roles_repository.dart';
import 'package:itk_app/data/repositories/admin/admin_users_repository.dart';
import 'package:itk_app/domain/models/user_summary.dart';
import 'package:itk_app/utils/result.dart';

import '../../helpers/fake_http.dart';

const _users = [
  {'userId': 7, 'fullName': 'Teszt Elek', 'ldapUsername': 'perpa4'},
];

void main() {
  late TestApiClient api;

  setUp(() => api = TestApiClient());

  group('AdminRolesRepository', () {
    late AdminRolesRepository repository;

    setUp(() => repository = AdminRolesRepository(apiClient: api));

    test('getRoleHolders a /api/admin/roles végpontról tölt', () async {
      api.adapter.handler = (_) => jsonBody(200, _users);

      final result = await repository.getRoleHolders();

      expect(api.adapter.last.method, 'GET');
      expect(api.adapter.last.path, '/api/admin/roles');
      expect(
          result,
          isA<Ok<List<UserSummary>>>()
              .having((r) => r.value.single.ldapUsername, 'login', 'perpa4'));
    });

    test('assignCohortRep a userId-t és a COHORT_REP szerepet küldi',
        () async {
      api.adapter.handler = (_) => jsonBody(200, null);

      final result = await repository.assignCohortRep(7);

      expect(result, isA<Ok<void>>());
      expect(api.adapter.last.method, 'POST');
      expect(api.adapter.last.path, '/api/admin/roles');
      expect(api.adapter.last.data, {'userId': 7, 'role': 'COHORT_REP'});
    });

    test('revokeRole a user id-s útvonalra küld DELETE-et', () async {
      api.adapter.handler = (_) => jsonBody(200, null);

      final result = await repository.revokeRole(7);

      expect(result, isA<Ok<void>>());
      expect(api.adapter.last.method, 'DELETE');
      expect(api.adapter.last.path, '/api/admin/roles/7');
    });

    test('szerverhiba: Err', () async {
      api.adapter.handler = (_) => jsonBody(500, null);

      expect(await repository.assignCohortRep(7), isA<Err<void>>());
      expect(await repository.revokeRole(7), isA<Err<void>>());
      expect(await repository.getRoleHolders(), isA<Err<List<UserSummary>>>());
    });
  });

  group('AdminUsersRepository', () {
    late AdminUsersRepository repository;

    setUp(() => repository = AdminUsersRepository(apiClient: api));

    test('get a /api/admin/users végpontról tölt', () async {
      api.adapter.handler = (_) => jsonBody(200, _users);

      final result = await repository.get();

      expect(api.adapter.last.path, '/api/admin/users');
      expect(
          result,
          isA<Ok<List<UserSummary>>>()
              .having((r) => r.value.single.userId, 'id', 7));
    });

    test('hibás elem (hiányzó név): Err', () async {
      api.adapter.handler = (_) => jsonBody(200, [
            {'userId': 7, 'ldapUsername': 'perpa4'},
          ]);

      expect(await repository.get(), isA<Err<List<UserSummary>>>());
    });
  });
}
