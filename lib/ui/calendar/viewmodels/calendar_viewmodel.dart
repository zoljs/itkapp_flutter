import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/foundation.dart';
import 'package:itk_app/data/repositories/calendar_repository.dart';
import 'package:itk_app/domain/models/calendar_event.dart';
import 'package:itk_app/utils/command.dart';
import 'package:itk_app/utils/result.dart';

class CalendarViewModel extends ChangeNotifier {
  final CalendarRepository _repository;
  final eventController = EventController<CalendarEvent>();

  CalendarViewModel({
    required CalendarRepository repository,
  }) : _repository = repository {
    load = Command1<void, bool>(_load)..execute(false);
  }

  late final Command1<void, bool> load;

  @override
  void dispose() {
    load.dispose();
    eventController.dispose();
    super.dispose();
  }

  // Methods
  Future<Result<void>> _load(bool forceReload) async {
    final result = await _repository.getCalendar(forceReload: forceReload);
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
