import 'package:itk_app/data/services/api_client.dart';
import 'package:itk_app/domain/models/calendar_link.dart';
import 'package:itk_app/utils/result.dart';

class CalendarLinksRepository {
  static const _path = '/api/calendar/v2/links';

  CalendarLinksRepository({
    required ApiClient apiClient,
  }) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<Result<List<CalendarLink>>> get() async => _apiClient.getJson(_path, parse: CalendarLink.parseList);

  Future<Result<void>> add({
    required String name,
    required String url,
    required SyncInterval syncInterval,
  }) async {
    final result = await _apiClient.post(
      _path,
      data: {
        'name': name,
        'url': url,
        'syncInterval': syncInterval.wire,
      },
    );
    return result;
  }

  Future<Result<void>> delete({
    required int id,
  }) async {
    final result = await _apiClient.delete('$_path/$id');
    return result;
  }
}
