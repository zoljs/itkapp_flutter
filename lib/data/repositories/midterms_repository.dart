import 'package:dio/dio.dart';
import 'package:itk_app/data/services/api_client.dart';
import 'package:itk_app/data/services/api_error.dart';
import 'package:itk_app/domain/models/midterm_date.dart';
import 'package:itk_app/utils/result.dart';

class MidtermsRepository {
  MidtermsRepository({
    required ApiClient apiClient,
  }) : _dio = apiClient.dio;

  final Dio _dio;

  Future<Result<List<MidtermDate>>> getMidterms() async {
    try {
      final response = await _dio.get('/api/midterms');
      final midterms = parseMidterms(response.data);
      return Ok(midterms);
    } on DioException catch (e) {
      return Err(apiErrorMessage(e));
    } on FormatException catch (e) {
      return Err(e.message);
    }
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

    return const Ok(null);
  }
}
