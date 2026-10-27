import 'package:flutter/foundation.dart';
import 'package:itk_app/data/repositories/auth_repository.dart';
import 'package:itk_app/domain/models/calendar_event.dart';
import 'package:itk_app/utils/command.dart';
import 'package:itk_app/utils/result.dart';
import 'package:itk_app/data/repositories/calendar_repository.dart';

class HomeViewModel extends ChangeNotifier {
  HomeViewModel({required AuthRepository authRepository, required CalendarRepository calendarRepository})
      : _authRepository = authRepository,
        _calendarRepository = calendarRepository {
    load = Command1<void, bool>(_load)..execute(false);
  }

  final AuthRepository _authRepository;
  final CalendarRepository _calendarRepository;

  @override
  void dispose() {
    load.dispose();
    super.dispose();
  }

  late final Command1<void, bool> load;

  // State
  CalendarEvent? _nextEvent;

  // Getters
  String? get firstName => _authRepository.cachedUser?.firstName;
  CalendarEvent? get nextEvent => _nextEvent;

  Future<Result<void>> _load(bool forceReload) async {
    final result = await _calendarRepository.getCalendar(forceReload: forceReload);

    if (result case Ok(:final value)) {
      final now = DateTime.now();
      final upcoming = value.where((e) => e.end.isAfter(now)).toList()..sort((a, b) => a.start.compareTo(b.start));
      _nextEvent = upcoming.firstOrNull;
      notifyListeners();
    }
    return result;
  }
}
