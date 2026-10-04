import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:itk_app/data/services/api_error.dart';

DioException withResponse(int status, [Object? data]) {
  final options = RequestOptions(path: '/x');
  return DioException.badResponse(
    statusCode: status,
    requestOptions: options,
    response: Response(requestOptions: options, statusCode: status, data: data),
  );
}

void main() {
  test('a hibakódot fordítja le, ha van', () {
    final e = withResponse(401, {
      'data': {'code': 'INVALID_CREDENTIALS'}
    });
    expect(apiErrorMessage(e), 'Hibás felhasználónév vagy jelszó!');
  });

  test('ismeretlen kódnál a státuszkódot használja', () {
    final e = withResponse(403, {
      'data': {'code': 'VALAMI_UJ'}
    });
    expect(apiErrorMessage(e), 'Ehhez nincs jogosultságod.');
  });

  test('üzenet nélkül a státuszkód alapján dönt', () {
    expect(apiErrorMessage(withResponse(403)), 'Ehhez nincs jogosultságod.');
    expect(apiErrorMessage(withResponse(503)), 'Hiba történt a szerveren.');
  });

  test('kapcsolati hibánál nem a státuszt nézi', () {
    final e = DioException.connectionError(
      requestOptions: RequestOptions(path: '/x'),
      reason: 'offline',
    );
    expect(apiErrorMessage(e), 'Nem sikerült kapcsolódni a szerverhez.');
  });
}
