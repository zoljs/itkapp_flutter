import 'dart:async';

import 'package:flutter/material.dart';
import 'package:infinite_calendar_view/infinite_calendar_view.dart'
    show Event, EventsController;
import 'package:itk_app/data/repositories/calendar_repository.dart';
import 'package:itk_app/domain/models/calendar_event.dart';
import 'package:itk_app/utils/command.dart';
import 'package:itk_app/utils/result.dart';

/// How many days the calendar shows side by side.
enum CalendarSpan {
  oneDay(1, 'Nap', Icons.calendar_view_day_rounded),
  threeDays(3, '3 nap', Icons.view_column_rounded),
  fiveDays(5, '5 nap', Icons.calendar_view_week_rounded);

  const CalendarSpan(this.days, this.label, this.icon);

  final int days;
  final String label;
  final IconData icon;

  CalendarSpan next() {
    if (this == CalendarSpan.oneDay) {
      return CalendarSpan.threeDays;
    } else if (this == CalendarSpan.threeDays) {
      return CalendarSpan.fiveDays;
    } else {
      return CalendarSpan.oneDay;
    }
  }
}

class CalendarViewModel extends ChangeNotifier {
  final CalendarRepository _repository;
  final eventController = EventsController();

  CalendarViewModel({
    required CalendarRepository repository,
  }) : _repository = repository {
    load = Command1<void, bool>(_load)..addListener(notifyListeners);
    _repository.addListener(_onCacheInvalidated);
    unawaited(load.execute(false));
  }

  late final Command1<void, bool> load;
  void _onCacheInvalidated() => unawaited(load.execute(false));

  bool _hasAllDayEvents = false;

  /// The all-day bar takes space, so it is only shown when there is
  /// something to put in it.
  bool get hasAllDayEvents => _hasAllDayEvents;

  CalendarSpan _span = CalendarSpan.threeDays;
  CalendarSpan get span => _span;

  void setSpan(CalendarSpan span) {
    if (span == _span) return;
    _span = span;
    notifyListeners();
  }

  /// Landscape always shows five days, whatever span is selected.
  int visibleDays({required bool landscape}) =>
      landscape ? CalendarSpan.fiveDays.days : span.days;

  @override
  void dispose() {
    _repository.removeListener(_onCacheInvalidated);
    load.dispose();
    eventController.dispose();
    super.dispose();
  }

  /// Turns calendar events into planner events.
  /// - Instant or broken events (end not after start) get a 15 minute block,
  ///   so they stay visible and the planner's `endTime.isAfter(startTime)`
  ///   assert holds.
  /// - All-day events ([CalendarEvent.isAllDay]) go to the planner's
  ///   all-day bar. The same end rules apply, so a one-day event stays on
  ///   its own day.
  /// - An end exactly at midnight is moved 1 minute back. The planner splits
  ///   multi-day events per day, and a 00:00-00:00 piece on the next day
  ///   would break the same assert (Neptun day-long events end at 00:00).
  static List<Event> toPlannerEvents(List<CalendarEvent> events) {
    return events.map((e) {
      final start = e.start.toLocal();
      return Event(
        isFullDay: e.isAllDay,
        startTime: start,
        endTime: displayEnd(start, e.end.toLocal()),
        title: e.title,
        description: e.location,
        data: e,
      );
    }).toList();
  }

  /// The end time the planner can draw for an event starting at [start].
  static DateTime displayEnd(DateTime start, DateTime end) {
    var result = end;
    if (_isMidnight(result) && result.isAfter(start)) {
      result = result.subtract(const Duration(minutes: 1));
    }
    if (!result.isAfter(start)) {
      result = start.add(const Duration(minutes: 15));
      // Keep the fallback block on the start day.
      if (_isMidnight(result) || result.day != start.day) {
        result = DateTime(start.year, start.month, start.day, 23, 59, 59);
      }
    }
    return result;
  }

  static bool _isMidnight(DateTime t) =>
      t.hour == 0 && t.minute == 0 && t.second == 0 && t.millisecond == 0;

  // Methods
  Future<Result<void>> _load(bool forceReload) async {
    final result = await _repository.get(forceReload: forceReload);

    if (result case Ok(:final value)) {
      final plannerEvents = toPlannerEvents(value);
      _hasAllDayEvents = value.any((e) => e.isAllDay);
      eventController.updateCalendarData((data) {
        data.clearAll();
        data.addEvents(plannerEvents);
      });
    }
    return result;
  }
}
