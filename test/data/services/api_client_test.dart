import 'package:flutter_test/flutter_test.dart';
import 'package:itk_app/data/services/api_client.dart';

void main() {
  final api = Uri.parse(ApiClient.baseUrl);
  Uri own(String path) => api.replace(path: path);

  group('isSessionExpired', () {
    test('401 a saját API-n lejárt session', () {
      expect(isSessionExpired(own('/api/sites'), 401), isTrue);
      expect(isSessionExpired(own('/api/auth/me'), 401), isTrue);
    });

    test('más státuszkód nem az', () {
      expect(isSessionExpired(own('/api/sites'), 200), isFalse);
      expect(isSessionExpired(own('/api/sites'), 403), isFalse);
      expect(isSessionExpired(own('/api/sites'), null), isFalse);
    });

    test('login és logout 401-e nem léptet ki', () {
      expect(isSessionExpired(own('/api/auth/login'), 401), isFalse);
      expect(isSessionExpired(own('/api/auth/logout'), 401), isFalse);
    });

    test('külső szerver 401-e nem léptet ki', () {
      final space = Uri.parse('https://space.itk.ppke.hu/api/subjects');
      expect(isSessionExpired(space, 401), isFalse);
    });
  });
}
