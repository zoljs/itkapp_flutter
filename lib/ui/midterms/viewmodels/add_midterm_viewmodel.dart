import 'package:flutter/material.dart';
import 'package:itk_app/data/services/midterms_service.dart';
import 'package:itk_app/domain/models/subject.dart';
import 'package:itk_app/utils/command.dart';
import 'package:itk_app/utils/result.dart';

class AddMidtermViewModel extends ChangeNotifier {
  AddMidtermViewModel({required MidtermsService service}) : _service = service {
    save = Command0<void>(_save);
  }

  factory AddMidtermViewModel.create() =>
      AddMidtermViewModel(service: MidtermsService.instance);

  // State
  final MidtermsService _service;
  late final Command0<void> save;

  Subject? _subject;
  DateTime? _date;
  TimeOfDay? _time;
  String _location = '';

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

  bool get canSave => _subject != null && _date != null && _time != null;
  DateTime? get startsAt {
    final date = _date;
    final time = _time;

    if (date == null || time == null) return null;
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  Future<Result<void>> _save() async {
    final subject = _subject;
    final startsAt = this.startsAt;

    if (subject == null || startsAt == null) {
      return const Err('Válassz tárgyat, dátumot és időpontot.');
    }

    final location = _location.trim();
    final result = await _service.addMidterm(
      subjectId: subject.id,
      startsAt: startsAt,
      location: location.isEmpty ? null : location,
    );

    return result;
  }
}
