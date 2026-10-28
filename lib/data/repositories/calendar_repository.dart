import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:icalendar_parser/icalendar_parser.dart';
import 'package:itk_app/data/services/api_error.dart';
import 'package:itk_app/data/services/send_request.dart';
import 'package:itk_app/domain/models/calendar_event.dart';
import 'package:itk_app/data/services/api_client.dart';
import 'package:itk_app/domain/models/calendar_links.dart';
import 'package:itk_app/utils/result.dart';

class CalendarRepository {
  CalendarRepository({
    required ApiClient apiClient,
  })  : _dio = apiClient.dio,
        _apiClient = apiClient;

  final Dio _dio;
  final ApiClient _apiClient;

  List<CalendarEvent>? _cached;

  Future<Result<List<CalendarEvent>>> getCalendar({
    bool forceReload = false,
  }) async {
    final cached = _cached;
    if (cached != null && !forceReload) return Ok(cached);

    // Reponse try
    final Response<dynamic> response;
    try {
      response = await _dio.get('/api/calendar');
    } on DioException catch (e) {
      // Does not have calendar aka empty
      if (e.response?.statusCode == 404) {
        _cached = const [];
        return const Ok([]);
      }
      return Err(apiErrorMessage(e));
    }

    // Extract data from response
    final data = response.data;
    if (data is! String || data.trim().isEmpty) {
      _cached = const [];
      return const Ok([]);
    }

    // Parse data from response
    try {
      final events = ICalendar.fromString(data).data.where((item) => item['type'] == 'VEVENT').map(CalendarEvent.fromJson).toList();
      _cached = events;
      return Ok(events);
    } catch (e) {
      debugPrint('[CalendarRepository] parse error: $e');
      return const Err('Nem sikerült feldolgozni a naptárat.');
    }
  }

  Future<Result<CalendarLinks>> getLinks() async => _apiClient.getJson('/api/calendar/links', parse: _parseCalendarLinks);

  CalendarLinks _parseCalendarLinks(Object? data) {
    if (data is! Map<String, dynamic>) {
      throw const FormatException('A naptár linkek helytelen formátumúak.');
    }
    return CalendarLinks.fromJson(data);
  }

  Future<Result<void>> saveLinks(CalendarLinks links) async {
    final result = await sendRequest(
      parse: (_) {},
      send: () => _dio.put(
        '/api/calendar/links',
        data: links.toJson(),
      ),
    );
    if (result is Ok) clearCache();
    return result;
  }

  void clearCache() => _cached = null;
}
