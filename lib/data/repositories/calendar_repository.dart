import 'package:itk_app/domain/models/calendar_event.dart';
import 'package:itk_app/data/services/api_client.dart';
import 'package:itk_app/utils/result.dart';

class CalendarRepository {
  static const _path = '/api/calendar';

  CalendarRepository({
    required ApiClient apiClient,
  }) : _apiClient = apiClient;

  final ApiClient _apiClient;

  List<CalendarEvent>? _cached;

  Future<Result<List<CalendarEvent>>> get({
    bool forceReload = false,
  }) async {
    final cached = _cached;
    if (cached != null && !forceReload) return Ok(cached);

    // Reponse try
    final result = await _apiClient.getJson(_path, parse: CalendarEvent.parseIcsResponse);
    if (result case Ok(:final value)) _cached = value;
    return result;
  }

  void clearCache() => _cached = null;
}
