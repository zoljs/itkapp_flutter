import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/foundation.dart';
import 'package:itk_app/data/services/calendar_service.dart';
import 'package:itk_app/domain/models/calendar_event.dart';
import 'package:itk_app/utils/command.dart';
import 'package:itk_app/utils/result.dart';

class CalendarViewModel extends ChangeNotifier {
  final CalendarService _calendarService;
  final eventController = EventController<CalendarEvent>();

  CalendarViewModel({
    required CalendarService calendarService,
  }) : _calendarService = calendarService {
    load = Command1<void, bool>(_load)..execute(false);
  }

  factory CalendarViewModel.create() => CalendarViewModel(
        calendarService: CalendarService.instance,
      );

  late final Command1<void, bool> load;

  // Methods
  Future<Result<void>> _load(bool forceReload) async {
    final result = await _calendarService.getCalendar(forceReload: forceReload);
    final List<CalendarEvent> events;

    switch (result) {
      case Ok(:final value):
        events = value;
      case Err(:final message):
        return Err(message);
    }

    final eventData = events.map((e) {
      final start = e.start.toLocal();
      final end = e.end.toLocal();
      final isInstant = end.isAtSameMomentAs(start);
      final displayEnd =
          isInstant ? start.add(const Duration(minutes: 15)) : end;

      return CalendarEventData<CalendarEvent>(
        date: start,
        startTime: start,
        endTime: displayEnd,
        title: e.title,
        event: e,
      );
    }).toList();

    eventController.removeWhere((_) => true);
    eventController.addAll(eventData);

    return const Ok(null);
  }
}
