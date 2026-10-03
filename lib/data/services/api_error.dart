import 'package:dio/dio.dart';

String apiErrorMessage(DioException e) {
  final serverMessage =
      e.response?.data is Map ? (e.response!.data as Map)['message'] : null;
  if (serverMessage is String && serverMessage.trim().isNotEmpty) {
    return serverMessage;
  }

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
