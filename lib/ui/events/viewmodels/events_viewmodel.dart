import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:itk_app/data/repositories/auth_repository.dart';
import 'package:itk_app/data/repositories/calendar_repository.dart';
import 'package:itk_app/data/repositories/event_repository.dart';
import 'package:itk_app/domain/models/event.dart';
import 'package:itk_app/utils/command.dart';
import 'package:itk_app/utils/result.dart';
import 'package:itk_app/utils/semester.dart';

class EventsViewModel extends ChangeNotifier {
  EventsViewModel({
    required EventRepository eventRepository,
    required CalendarRepository calendarRepository,
    required AuthRepository authRepository,
    required Set<EventType> types,
  })  : _authRepository = authRepository,
        _eventRepository = eventRepository,
        _calendarRepository = calendarRepository,
        _types = types {
    load = Command1<void, bool>(_load);
    unawaited(load.execute(false));
    delete = Command1<void, int>(_delete);
  }

  final EventRepository _eventRepository;
  final CalendarRepository _calendarRepository;
  final AuthRepository _authRepository;
  late final Command1<void, bool> load;
  late final Command1<void, int> delete;

  final Set<EventType> _types;
  final semesterStart = currentSemesterStart();

  @override
  void dispose() {
    load.dispose();
    delete.dispose();
    super.dispose();
  }

  // State
  String _query = '';
  List<Event> _events = [];
  bool get canModerate =>
      _authRepository.cachedUser?.canModerateMidterms ?? false;
  Set<String> _mySubjects = {};
  bool _onlyMySubjects = false;
  final Set<EventType> _selectedTypes = {};

  // Getters
  UnmodifiableListView<Event> get events => UnmodifiableListView(_events);
  UnmodifiableSetView<EventType> get types => UnmodifiableSetView(_types);

  String get query => _query;
  void setQuery(String value) {
    _query = value;
    notifyListeners();
  }

  bool get initialLoading => load.running && _events.isEmpty;

  UnmodifiableSetView<String> get mySubjects =>
      UnmodifiableSetView(_mySubjects);
  bool get hasMySubjects => _mySubjects.isNotEmpty;
  bool get onlyMySubjects => _onlyMySubjects;
  void setOnlyMySubjects(bool value) {
    _onlyMySubjects = value;
    notifyListeners();
  }

  UnmodifiableSetView<EventType> get selectedTypes =>
      UnmodifiableSetView(_selectedTypes);

  void setTypeSelected(EventType type, bool selected) {
    if (selected) {
      _selectedTypes.add(type);
    } else {
      _selectedTypes.remove(type);
    }
    notifyListeners();
  }

  bool get isSubjectFilterActive => _onlyMySubjects && hasMySubjects;

  List<Event> get filteredEvents {
    final q = _query.trim().toLowerCase();

    return events.where((e) {
      final passes =
          !isSubjectFilterActive || mySubjects.contains(e.subject.name);
      final matchesSearch = q.isEmpty ||
          e.subject.name.toLowerCase().contains(q) ||
          e.subject.code.toLowerCase().contains(q) ||
          (e.location?.toLowerCase().contains(q) ?? false);
      final matchesType =
          _selectedTypes.isEmpty || _selectedTypes.contains(e.type);
      return passes && matchesSearch && matchesType;
    }).toList();
  }

  Future<Result<void>> _load(bool forceReload) async {
    final calendarFuture = _calendarRepository.get(forceReload: forceReload);

    final eventsResult =
        await _eventRepository.get(forceReload: forceReload, types: _types);
    if (eventsResult case Ok(:final value)) {
      _events = value;
      notifyListeners();
    }

    final calendarResult = await calendarFuture;
    if (calendarResult case Ok(:final value)) {
      _mySubjects = value
          .where((event) => !event.start.isBefore(semesterStart))
          .map((event) => event.subject)
          .nonNulls
          .toSet();
      notifyListeners();
    }

    return eventsResult;
  }

  Future<Result<void>> _delete(int id) async {
    _events = _events.where((m) => m.id != id).toList();
    notifyListeners();
    final result = await _eventRepository.delete(id: id);
    if (result is Err) await _load(true);
    return result;
  }
}
