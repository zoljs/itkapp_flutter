import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:itk_app/data/repositories/absolutorium_repository.dart';
import 'package:itk_app/data/repositories/auth_repository.dart';
import 'package:itk_app/domain/models/calendar_event.dart';
import 'package:itk_app/utils/command.dart';
import 'package:itk_app/utils/result.dart';
import 'package:itk_app/data/repositories/calendar_repository.dart';

class HomeViewModel extends ChangeNotifier {
  HomeViewModel({
    required AuthRepository authRepository,
    required CalendarRepository calendarRepository,
    required AbsolutoriumRepository absolutoriumRepository,
  })  : _authRepository = authRepository,
        _calendarRepository = calendarRepository,
        _absolutoriumRepository = absolutoriumRepository {
    load = Command1<void, bool>(_load);
    _absolutoriumRepository.progress.addListener(notifyListeners);
    unawaited(load.execute(false));
  }

  final AuthRepository _authRepository;
  final CalendarRepository _calendarRepository;
  final AbsolutoriumRepository _absolutoriumRepository;

  @override
  void dispose() {
    _absolutoriumRepository.progress.removeListener(notifyListeners);
    load.dispose();
    super.dispose();
  }

  late final Command1<void, bool> load;

  CalendarEvent? _nextEvent;

  String? get firstName => _authRepository.cachedUser?.firstName;

  CalendarEvent? get nextEvent => _nextEvent;

  String? get absolutoriumSummary {
    final p = _absolutoriumRepository.progress.value;
    return p == null ? null : '${p.earnedCredits}/${p.requiredCredits} kr';
  }

  Future<Result<void>> _load(bool forceReload) async {
    unawaited(_absolutoriumRepository.getProgress(forceReload: forceReload));
    final result = await _calendarRepository.get(forceReload: forceReload);

    if (result case Ok(:final value)) {
      final now = DateTime.now();
      final upcoming = value.where((e) => e.end.isAfter(now)).toList()
        ..sort((a, b) => a.start.compareTo(b.start));
      _nextEvent = upcoming.firstOrNull;
      notifyListeners();
    }
    return result;
  }
}
