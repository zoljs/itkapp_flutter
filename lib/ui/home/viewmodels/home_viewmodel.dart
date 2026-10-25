import 'package:flutter/foundation.dart';
import 'package:itk_app/data/services/auth_service.dart';
import 'package:itk_app/domain/models/calendar_event.dart';
import 'package:itk_app/utils/command.dart';
import 'package:itk_app/utils/result.dart';
import 'package:itk_app/data/services/calendar_service.dart';

class HomeViewModel extends ChangeNotifier {
  HomeViewModel(
      {required AuthService authService,
      required CalendarService calendarService})
      : _authService = authService,
        _calendarService = calendarService {
    load = Command1<void, bool>(_load)..execute(false);
  }

  factory HomeViewModel.create() => HomeViewModel(
      authService: AuthService.instance,
      calendarService: CalendarService.instance);

  final AuthService _authService;
  final CalendarService _calendarService;

  late final Command1<void, bool> load;

  // State
  CalendarEvent? _nextEvent;

  // Getters
  String? get firstName => _authService.cachedUser?.firstName;
  CalendarEvent? get nextEvent => _nextEvent;

  Future<Result<void>> _load(bool forceReload) async {
    final result = await _calendarService.getCalendar(forceReload: forceReload);

    switch (result) {
      case Ok(:final value):
        final now = DateTime.now();
        final upcoming = value.where((e) => e.end.isAfter(now)).toList()
          ..sort((a, b) => a.start.compareTo(b.start));
        _nextEvent = upcoming.firstOrNull;
        notifyListeners();
        return const Ok(null);
      case Err(:final message):
        return Err(message);
    }
  }
}
