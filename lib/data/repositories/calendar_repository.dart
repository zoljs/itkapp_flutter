import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:icalendar_parser/icalendar_parser.dart';
import 'package:itk_app/data/services/api_error.dart';
import 'package:itk_app/domain/models/calendar_event.dart';
import 'package:itk_app/data/services/api_client.dart';
import 'package:itk_app/utils/result.dart';

class CalendarRepository {
  CalendarRepository({
    required ApiClient apiClient,
  }) : _dio = apiClient.dio;

  static final instance = CalendarRepository(apiClient: ApiClient.instance);
  final Dio _dio;

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
      final events = ICalendar.fromString(data)
          .data
          .where((item) => item['type'] == 'VEVENT')
          .map(CalendarEvent.fromJson)
          .toList();
      _cached = events;
      return Ok(events);
    } catch (e) {
      debugPrint('[CalendarRepository] parse error: $e');
      return const Err('Nem sikerült feldolgozni a naptárat.');
    }
  }

  void clearCache() => _cached = null;
}
