import 'package:dio/dio.dart';
import 'package:icalendar_parser/icalendar_parser.dart';
import 'package:itk_app/models/calendar_event.dart';
import 'package:itk_app/services/api_client.dart';
import 'package:itk_app/services/auth_service.dart';

class CalendarService {
  CalendarService.internal();
  static final CalendarService instance = CalendarService.internal();
  final Dio _dio = ApiClient.instance.dio;

  List<CalendarEvent> _cachedEvents = [];
  bool _hasFetchedCalendar = false;

  Future<List<CalendarEvent>> getCalendar({bool forceReload = false}) async {
    final username = AuthService.instance.cachedUser?.login;
    if (username == null) return [];

    if (_hasFetchedCalendar && !forceReload) {
      return _cachedEvents;
    }

    final response = await _dio.get('/api/calendar/$username');
    final icsText = response.data as String;
    final calendar = ICalendar.fromString(icsText);

    final events = calendar.data
        .where((item) => item['type'] == 'VEVENT')
        .map((item) => CalendarEvent.fromJson(item))
        .toList();

    _cachedEvents = events;
    _hasFetchedCalendar = true;
    return events;
  }
}
