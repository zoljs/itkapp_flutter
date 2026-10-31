import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:itk_app/data/repositories/auth_repository.dart';
import 'package:itk_app/data/repositories/event_repository.dart';
import 'package:itk_app/domain/models/event.dart';
import 'package:itk_app/utils/command.dart';
import 'package:itk_app/utils/result.dart';

class EventsViewModel extends ChangeNotifier {
  EventsViewModel({
    required EventRepository eventRepository,
    required AuthRepository authRepository,
    required Set<EventType> types,
  })  : _authRepository = authRepository,
        _eventRepository = eventRepository,
        _types = types {
    load = Command1<void, bool>(_load);
    unawaited(load.execute(false));
    delete = Command1<void, int>(_delete);
  }

  final EventRepository _eventRepository;
  final AuthRepository _authRepository;
  late final Command1<void, bool> load;
  late final Command1<void, int> delete;

  final Set<EventType> _types;

  @override
  void dispose() {
    load.dispose();
    delete.dispose();
    super.dispose();
  }

  // State
  String _query = '';
  List<Event> _events = [];
  bool get canModerate => _authRepository.cachedUser?.canModerateMidterms ?? false;

  // Getters
  UnmodifiableListView<Event> get events => UnmodifiableListView(_events);

  String get query => _query;
  void setQuery(String value) {
    _query = value;
    notifyListeners();
  }

  List<Event> get filteredEvents {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return events;
    return events.where((m) => m.subject.name.toLowerCase().contains(q) || m.subject.code.toLowerCase().contains(q) || (m.location?.toLowerCase().contains(q) ?? false)).toList();
  }

  bool get initialLoading => load.running && _events.isEmpty;

  Future<Result<void>> _load(bool forceReload) async {
    final result = await _eventRepository.get(forceReload: forceReload, types: _types);

    if (result case Ok(:final value)) {
      _events = value;
      notifyListeners();
    }
    return result;
  }

  Future<Result<void>> _delete(int id) async {
    _events = _events.where((m) => m.id != id).toList();
    notifyListeners();
    final result = await _eventRepository.delete(id: id);
    if (result is Err) await _load(true);
    return result;
  }
}
