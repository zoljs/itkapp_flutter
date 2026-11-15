import 'package:flutter/foundation.dart';
import 'package:itk_app/data/services/offline_store.dart';
import 'package:itk_app/domain/models/calendar_event.dart';
import 'package:itk_app/data/services/api_client.dart';
import 'package:itk_app/utils/result.dart';

class CalendarRepository extends ChangeNotifier {
  static const _path = '/api/calendar';

  CalendarRepository({
    required ApiClient apiClient,
    required OfflineStore offlineStore,
  })  : _apiClient = apiClient,
        _offlineStore = offlineStore;

  final ApiClient _apiClient;
  final OfflineStore _offlineStore;
  static const _offlineKey = 'calendar';

  List<CalendarEvent>? _cached;
  DateTime? _offlineSince;

  DateTime? get offlineSince => _offlineSince;

  Future<Result<List<CalendarEvent>>> get({
    bool forceReload = false,
  }) async {
    final cached = _cached;
    if (cached != null && !forceReload) return Ok(cached);

    Object? raw;
    // Reponse try
    final result = await _apiClient.getJson(_path, parse: (data) {
      final events = CalendarEvent.parseIcsResponse(data);
      raw = data;
      return events;
    });
    _offlineSince = null;
    if (result case Ok(:final value)) {
      _cached = value;
      await _offlineStore.write(_offlineKey, raw);
    }
    if (result is Err) {
      final store = await _offlineStore.read(_offlineKey);
      if (store == null) return result;
      final data = store.data;
      if (data == null) return result;

      try {
        final events = CalendarEvent.parseIcsResponse(data);
        _offlineSince = store.savedAt;
        return Ok(events);
      } on FormatException {
        return result;
      }
    }
    return result;
  }

  void clearCache() => _cached = null;

  void invalidateCache() {
    clearCache();
    notifyListeners();
  }
}
