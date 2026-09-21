import 'package:dio/dio.dart';
import 'package:icalendar_parser/icalendar_parser.dart';
import 'package:itk_app/models/calendar_event.dart';
import 'package:itk_app/services/api_client.dart';

class CalendarService {
  CalendarService.internal();
  static final CalendarService instance = CalendarService.internal();
  final Dio _dio = ApiClient.instance.dio;

  Future<void> getCalendar(String username) async {
    final response = await _dio.get('/api/calendar/$username');
    final icsText = response.data as String;
    final calendar = ICalendar.fromString(icsText);

    final events = calendar.data
        .where((item) => item['type'] == 'VEVENT')
        .map((item) => CalendarEvent.fromJson(item))
        .toList();
  }
}
