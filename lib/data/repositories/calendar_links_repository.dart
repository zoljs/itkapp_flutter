import 'package:dio/dio.dart';
import 'package:itk_app/data/services/api_client.dart';
import 'package:itk_app/data/services/send_request.dart';
import 'package:itk_app/domain/models/calendar_link.dart';
import 'package:itk_app/utils/result.dart';

class CalendarLinksRepository {
  static const _path = '/api/calendar/v2/links';

  CalendarLinksRepository({
    required ApiClient apiClient,
  })  : _dio = apiClient.dio,
        _apiClient = apiClient;

  final Dio _dio;
  final ApiClient _apiClient;

  Future<Result<List<CalendarLink>>> get() async => _apiClient.getJson(_path, parse: CalendarLink.parseList);

  Future<Result<void>> add({
    required String name,
    required String url,
    required SyncInterval syncInterval,
  }) async {
    final result = await sendRequest(
      parse: (_) {},
      send: () => _dio.post(
        _path,
        data: {
          'name': name,
          'url': url,
          'syncInterval': syncInterval.wire,
        },
      ),
    );
    return result;
  }

  Future<Result<void>> delete({
    required int id,
  }) async {
    final result = await sendRequest(
      parse: (_) {},
      send: () => _dio.delete('$_path/$id'),
    );
    return result;
  }
}
