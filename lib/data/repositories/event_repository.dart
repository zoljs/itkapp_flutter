import 'package:itk_app/data/services/api_client.dart';
import 'package:itk_app/data/services/offline_store.dart';
import 'package:itk_app/domain/models/event.dart';
import 'package:itk_app/utils/result.dart';

class EventRepository {
  static const _path = '/api/midterms';

  EventRepository({
    required ApiClient apiClient,
    required OfflineStore offlineStore,
  })  : _offlineStore = offlineStore,
        _apiClient = apiClient;

  final ApiClient _apiClient;
  final OfflineStore _offlineStore;
  static const _offlineKeyBase = 'events';

  //List<Event>? _cached;
  final Map<String, List<Event>> _cache = {};
  DateTime? _offlineSince;

  DateTime? get offlineSince => _offlineSince;
  //void clearCache() => _cached = null;
  void clearCache() => _cache.clear();

  Future<Result<List<Event>>> get({
    required Set<EventType> types,
    bool forceReload = false,
  }) async {
    // types: [MIDTERM, RETAKE] -> "MIDTERM,RETAKE"
    final String key =
        (types.map((type) => type.wire).toList()..sort()).join(',');
    final offlineKey = '${_offlineKeyBase}_$key';
    final cache = _cache[key];
    if (cache != null && !forceReload) return Ok(cache);

    Object? raw;
    final result = await _apiClient.getJson(
      _path,
      parse: (data) {
        final events = Event.parseList(data);
        raw = data;
        return events;
      },
      queryParameters: {'type': key},
    );
    _offlineSince = null;
    if (result case Ok(:final value)) {
      _cache[key] = value;
      await _offlineStore.write(offlineKey, raw);
    }
    if (result is Err) {
      final store = await _offlineStore.read(offlineKey);
      if (store == null) return result;
      final data = store.data;
      if (data == null) return result;

      try {
        final events = Event.parseList(data);
        _offlineSince = store.savedAt;
        return Ok(events);
      } on FormatException {
        return result;
      }
    }
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
