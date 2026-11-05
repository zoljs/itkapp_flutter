import 'package:flutter/material.dart';
import 'package:itk_app/data/repositories/event_repository.dart';
import 'package:itk_app/domain/models/event.dart';
import 'package:itk_app/domain/models/subject.dart';
import 'package:itk_app/utils/command.dart';
import 'package:itk_app/utils/result.dart';

class AddEventViewModel extends ChangeNotifier {
  AddEventViewModel({
    required EventRepository repository,
    required Set<EventType> allowedTypes,
  })  : _repository = repository,
        _allowedTypes = allowedTypes {
    save = Command0<void>(_save)..addListener(notifyListeners);
  }

  // State
  final EventRepository _repository;
  late final Command0<void> save;
  final Set<EventType> _allowedTypes;
  late EventType _type = _allowedTypes.first;

  Subject? _subject;
  DateTime? _date;
  TimeOfDay? _time;
  String _location = '';

  @override
  void dispose() {
    save.dispose();
    super.dispose();
  }

  // Getters
  Subject? get subject => _subject;
  void setSubject(Subject value) {
    _subject = value;
    notifyListeners();
  }

  DateTime? get date => _date;
  void setDate(DateTime value) {
    _date = value;
    notifyListeners();
  }

  TimeOfDay? get time => _time;
  void setTime(TimeOfDay value) {
    _time = value;
    notifyListeners();
  }

  void setLocation(String value) {
    _location = value;
    notifyListeners();
  }

  bool get canSave =>
      _subject != null && _date != null && _time != null && !save.running;
  DateTime? get startsAt {
    final date = _date;
    final time = _time;

    if (date == null || time == null) return null;
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  EventType get type => _type;
  void setType(EventType type) {
    _type = type;
    notifyListeners();
  }

  Future<Result<void>> _save() async {
    final subject = _subject;
    final startsAt = this.startsAt;

    if (subject == null || startsAt == null) {
      return const Err('Válassz tárgyat, dátumot és időpontot.');
    }

    final location = _location.trim();
    final result = await _repository.add(
      subjectId: subject.id,
      startsAt: startsAt,
      location: location.isEmpty ? null : location,
      type: type,
    );

    return result;
  }
}
