import 'package:itk_app/data/services/api_client.dart';
import 'package:itk_app/domain/models/event.dart';
import 'package:itk_app/utils/result.dart';

class EventRepository {
  static const _path = '/api/midterms';

  EventRepository({
    required ApiClient apiClient,
  }) : _apiClient = apiClient;

  final ApiClient _apiClient;

  //List<Event>? _cached;
  final Map<String, List<Event>> _cache = {};

  //void clearCache() => _cached = null;
  void clearCache() => _cache.clear();

  Future<Result<List<Event>>> get({
    required Set<EventType> types,
    bool forceReload = false,
  }) async {
    // types: [MIDTERM, RETAKE] -> "MIDTERM,RETAKE"
    final String key =
        (types.map((type) => type.wire).toList()..sort()).join(',');
    final cache = _cache[key];
    if (cache != null && !forceReload) return Ok(cache);

    final result = await _apiClient.getJson(
      _path,
      parse: Event.parseList,
      queryParameters: {'type': key},
    );
    if (result case Ok(:final value)) _cache[key] = value;
    return result;
  }

  Future<Result<void>> add({
    required int subjectId,
    required DateTime startsAt,
    String? location,
    required EventType type,
  }) async {
    final result = await _apiClient.post(
      _path,
      data: {
        'subjectId': subjectId,
        'startsAt': startsAt.toUtc().toIso8601String(),
        if (location != null) 'location': location,
        'type': type.wire,
      },
    );
    if (result is Ok) clearCache();
    return result;
  }

  Future<Result<void>> delete({
    required int id,
  }) async {
    final result = await _apiClient.delete('$_path/$id');
    if (result is Ok) clearCache();
    return result;
  }
}
