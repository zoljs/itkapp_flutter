import 'package:dio/dio.dart';

const _errorMessages = {
  'MISSING_CREDENTIALS': 'Add meg a felhasználónevet és a jelszót!',
  'INVALID_CREDENTIALS': 'Hibás felhasználónév vagy jelszó!',
  'INVALID_URL': 'Érvénytelen URL.',
  'INVALID_SYNC_INTERVAL': 'Érvénytelen frissítési időköz.',
  'INVALID_BODY': 'Hibás adatok.',
  'NAME_EMPTY': 'A név nem lehet üres.',
  'NAME_TOO_LONG': 'A név legfeljebb 50 karakter lehet.',
  'TOO_MANY_LINKS': 'Legfeljebb 10 naptárat adhatsz hozzá.',
  'DUPLICATE_LINK': 'Ez a link már fel van véve.',
  'LINK_NOT_FOUND': 'Ez a link már nem létezik.',
  'INVALID_ID': 'Érvénytelen azonosító.',
};

// Sent by server
String? _errorCode(DioException e) {
  final body = e.response?.data;
  if (body is! Map) return null;
  final data = body['data'];
  if (data is! Map) return null;
  final code = data['code'];
  return code is String ? code : null;
}

// Network errors
String apiErrorMessage(DioException e) {
  final known = _errorMessages[_errorCode(e)];
  if (known != null) return known;

  switch (e.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.receiveTimeout:
    case DioExceptionType.sendTimeout:
      return 'Időtúllépés: a szerver nem válaszol.';
    case DioExceptionType.connectionError:
      return 'Nem sikerült kapcsolódni a szerverhez.';
    default:
      break;
  }

  return switch (e.response?.statusCode) {
    401 => 'Lejárt a munkamenet, jelentkezz be újra.',
    403 => 'Ehhez nincs jogosultságod.',
    404 => 'A keresett adat nem található.',
    final int code when code >= 500 => 'Hiba történt a szerveren.',
    _ => 'Váratlan hiba történt.',
  };
}
