import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:itk_app/data/repositories/calendar_repository.dart';
import 'package:itk_app/domain/models/calendar_links.dart';
import 'package:itk_app/utils/command.dart';
import 'package:itk_app/utils/result.dart';

class CalendarLinksViewmodel extends ChangeNotifier {
  final CalendarRepository _repository;
  late final Command0<void> load;
  late final Command0<void> save;

  CalendarLinks? _links;
  CalendarLinks? get links => _links;

  String _neptunUrl = '';
  String _moodleUrl = '';

  String get neptunUrl => _neptunUrl;
  String get moodleUrl => _moodleUrl;

  void setNeptunUrl(String value) {
    debugPrint('setNeptunUrl: $value');

    _neptunUrl = value;
    notifyListeners();
  }

  void setMoodleUrl(String value) {
    _moodleUrl = value;
    notifyListeners();
  }

  CalendarLinksViewmodel({
    required CalendarRepository repository,
  }) : _repository = repository {
    load = Command0<void>(_load);
    save = Command0<void>(_save);
    unawaited(load.execute());
  }

  Future<Result<void>> _load() async {
    final result = await _repository.getLinks();
    if (result case Ok(:final value)) {
      _links = value;
      _neptunUrl = value.neptunUrl ?? '';
      _moodleUrl = value.moodleUrl ?? '';
      notifyListeners();
    }
    return result;
  }

  bool get canSave => _links != null && !save.running;

  Future<Result<void>> _save() async {
    final result = await _repository.saveLinks(
      CalendarLinks(
        neptunUrl: _neptunUrl.trim().isEmpty ? null : _neptunUrl.trim(),
        moodleUrl: _moodleUrl.trim().isEmpty ? null : moodleUrl.trim(),
      ),
    );
    if (result is Ok) return _load();
    return result;
  }

  @override
  void dispose() {
    load.dispose();
    save.dispose();
    super.dispose();
  }
}
