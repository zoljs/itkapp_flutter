import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:itk_app/data/repositories/auth_repository.dart';
import 'package:itk_app/data/services/shared_preferences_service.dart';
import 'package:itk_app/domain/models/user.dart';
import 'package:itk_app/utils/result.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/fake_http.dart';
import '../../helpers/fixtures.dart';

const _cacheKey = 'cached_user';

void main() {
  late TestApiClient api;
  late SharedPreferences rawPrefs;
  late AuthRepository repository;

  Future<void> build({Map<String, Object> stored = const {}}) async {
    SharedPreferences.setMockInitialValues(stored);
    rawPrefs = await SharedPreferences.getInstance();
    api = TestApiClient();
    repository = AuthRepository(
        apiClient: api, prefs: SharedPreferencesService(rawPrefs));
  }

  /// Answers /login with [loginStatus] and /me with [meStatus] + [meBody].
  void respond({int loginStatus = 200, int meStatus = 200, Object? meBody}) {
    api.adapter.handler = (options) => switch (options.path) {
          '/api/auth/login' => jsonBody(loginStatus, null),
          '/api/auth/me' => jsonBody(meStatus, meBody ?? user().toJson()),
          _ => jsonBody(200, null),
        };
  }

  group('login', () {
    setUp(() => build());

    test('sikeres login + /me: Ok, bejelentkezve, user elmentve', () async {
      respond();

      final result = await repository.login('perpa4', 'jelszo');

      expect(result, isA<Ok<void>>());
      expect(repository.isAuthenticated, isTrue);
      expect(repository.cachedUser?.login, 'perpa4');
      expect(rawPrefs.getString(_cacheKey), isNotNull);
    });

    test('hibás jelszó: Err, a /me-t meg sem hívja', () async {
      respond(loginStatus: 401);

      final result = await repository.login('perpa4', 'rossz');

      expect(result, isA<Err<void>>());
      expect(repository.isAuthenticated, isFalse);
      expect(api.adapter.requests, hasLength(1));
    });

    // Regression: the old code returned Ok even when /me failed.
    test('login Ok, de a /me 500: Err, nincs bejelentkezve', () async {
      respond(meStatus: 500);

      final result = await repository.login('perpa4', 'jelszo');

      expect(result, isA<Err<void>>());
      expect(repository.isAuthenticated, isFalse);
      expect(rawPrefs.getString(_cacheKey), isNull);
    });

    test('login Ok, de a /me hibás JSON: Err, nincs bejelentkezve', () async {
      respond(meBody: {'id': 'nem szam'});

      final result = await repository.login('perpa4', 'jelszo');

      expect(result, isA<Err<void>>());
      expect(repository.isAuthenticated, isFalse);
    });
  });

  group('refreshUser', () {
    setUp(() => build());

    test('siker: Ok a userrel', () async {
      respond();

      final result = await repository.refreshUser();

      expect(result, isA<Ok<LdapUser>>());
      expect(repository.cachedUser?.login, 'perpa4');
    });

    test('hiba: Err, nem dob', () async {
      respond(meStatus: 500);

      final result = await repository.refreshUser();

      expect(result, isA<Err<LdapUser>>());
    });
  });

  group('logout', () {
    setUp(() => build(stored: {_cacheKey: jsonEncode(user().toJson())}));

    test('a lemezről betöltött user bejelentkezettnek számít', () {
      expect(repository.isAuthenticated, isTrue);
    });

    test('szerverhiba esetén is kilép helyben', () async {
      api.adapter.handler = (_) => jsonBody(500, null);

      await repository.logout();

      expect(repository.isAuthenticated, isFalse);
      expect(rawPrefs.getString(_cacheKey), isNull);
    });
  });
}
