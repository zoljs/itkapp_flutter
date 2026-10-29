import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:itk_app/data/repositories/calendar_links_repository.dart';
import 'package:itk_app/data/repositories/calendar_repository.dart';
import 'package:itk_app/domain/models/calendar_link.dart';
import 'package:itk_app/utils/command.dart';
import 'package:itk_app/utils/result.dart';

class CalendarLinksViewmodel extends ChangeNotifier {
  final CalendarLinksRepository _repository;
  final CalendarRepository _calendarRepository;
  late final Command0<void> load;
  late final Command0<void> add;
  late final Command1<void, int> delete;

  CalendarLinksViewmodel({
    required CalendarLinksRepository repository,
    required CalendarRepository calendarRepository,
  })  : _repository = repository,
        _calendarRepository = calendarRepository {
    load = Command0<void>(_load);
    add = Command0<void>(_add);
    delete = Command1<void, int>(_delete);
    unawaited(load.execute());
  }

  // State
  List<CalendarLink> _links = [];
  String _name = '';
  String _url = '';
  SyncInterval _syncInterval = SyncInterval.daily;

  // Getters
  bool get initialLoading => load.running && _links.isEmpty;
  UnmodifiableListView<CalendarLink> get links => UnmodifiableListView(_links);
  SyncInterval get syncInterval => _syncInterval;
  bool get isFull => _links.length >= 10;
  bool get canAdd => _name.trim().isNotEmpty && _url.trim().isNotEmpty && !add.running && !isFull;

  // Setters
  void setName(String value) {
    _name = value;
    notifyListeners();
  }

  void setUrl(String value) {
    _url = value;
    notifyListeners();
  }

  void setSyncInterval(SyncInterval value) {
    _syncInterval = value;
    notifyListeners();
  }

  // Methods
  Future<Result<void>> _load() async {
    final result = await _repository.get();
    if (result case Ok(:final value)) {
      _links = value;
      notifyListeners();
    }
    return result;
  }

  Future<Result<void>> _add() async {
    final result = await _repository.add(
      name: _name.trim(),
      url: _url.trim(),
      syncInterval: _syncInterval,
    );
    if (result case Ok()) {
      setName('');
      setUrl('');
      _calendarRepository.clearCache();
      return _load();
    }
    return result;
  }

  Future<Result<void>> _delete(int id) async {
    _links = _links.where((link) => link.id != id).toList();
    notifyListeners();

    final result = await _repository.delete(id: id);
    if (result case Ok()) {
      _calendarRepository.clearCache();
      return _load();
    }
    return result;
  }

  @override
  void dispose() {
    load.dispose();
    add.dispose();
    delete.dispose();
    super.dispose();
  }
}
