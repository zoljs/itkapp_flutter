import 'package:dio/dio.dart';
import 'package:itk_app/data/services/api_client.dart';
import 'package:itk_app/data/services/send_request.dart';
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

  Future<Result<List<MidtermDate>>> getMidterms({bool forceReload = false}) async {
    final cached = _cached;
    if (cached != null && !forceReload) return Ok(cached);

    final result = await _apiClient.getJson('/api/midterms', parse: MidtermDate.parseList);
    if (result case Ok(:final value)) _cached = value;
    return result;
  }

  Future<Result<void>> addMidterm({
    required int subjectId,
    required DateTime startsAt,
    String? location,
  }) async {
    final result = await sendRequest(
      parse: (_) {},
      send: () => _dio.post(
        '/api/midterms',
        data: {
          'subjectId': subjectId,
          'startsAt': startsAt.toUtc().toIso8601String(),
          if (location != null) 'location': location,
        },
      ),
    );
    if (result is Ok) clearCache();
    return result;
  }

  Future<Result<void>> deleteMidterm({
    required int midtermId,
  }) async {
    final result = await sendRequest(parse: (_) {}, send: () => _dio.delete('/api/midterms/$midtermId'));
    if (result is Ok) clearCache();
    return result;
  }
}
