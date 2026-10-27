import 'package:dio/dio.dart';
import 'package:itk_app/data/services/api_client.dart';
import 'package:itk_app/data/services/api_error.dart';
import 'package:itk_app/domain/models/midterm_date.dart';
import 'package:itk_app/utils/result.dart';

class MidtermsRepository {
  MidtermsRepository({
    required ApiClient apiClient,
  })  : _dio = apiClient.dio,
        _apiClient = apiClient;

  final ApiClient _apiClient;
  final Dio _dio;

  List<MidtermDate>? _cached;

  void clearCache() => _cached = null;

  Future<Result<List<MidtermDate>>> getMidterms(
      {bool forceReload = false}) async {
    final cached = _cached;
    if (cached != null && !forceReload) return Ok(cached);

    final result =
        await _apiClient.getJson('/api/midterms', parse: parseMidterms);
    if (result case Ok(:final value)) _cached = value;
    return result;
  }

  List<MidtermDate> parseMidterms(Object? data) {
    if (data is! List) {
      throw const FormatException('A zh lista nem lista formátumú.');
    }

    final midtermDates = <MidtermDate>[];
    for (final entry in data) {
      if (entry is! Map<String, dynamic>) {
        throw const FormatException('Egy zh nem objektum formátumú.');
      }
      midtermDates.add(MidtermDate.fromJson(entry));
    }
    return List.unmodifiable(midtermDates);
  }

  Future<Result<void>> addMidterm({
    required int subjectId,
    required DateTime startsAt,
    String? location,
  }) async {
    try {
      await _dio.post(
        '/api/midterms',
        data: {
          'subjectId': subjectId,
          'startsAt': startsAt.toUtc().toIso8601String(),
          if (location != null) 'location': location,
        },
      );
    } on DioException catch (e) {
      return Err(apiErrorMessage(e));
    }
    clearCache();
    return const Ok(null);
  }

  Future<Result<void>> deleteMidterm({
    required int midtermId,
  }) async {
    try {
      await _dio.delete('/api/midterms/$midtermId');
    } on DioException catch (e) {
      return Err(apiErrorMessage(e));
    }
    clearCache();
    return const Ok(null);
  }
}
