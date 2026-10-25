import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:itk_app/data/services/auth_service.dart';
import 'package:itk_app/data/services/midterms_service.dart';
import 'package:itk_app/domain/models/midterm_date.dart';
import 'package:itk_app/utils/command.dart';
import 'package:itk_app/utils/result.dart';

class MidtermsViewModel extends ChangeNotifier {
  MidtermsViewModel({
    required MidtermsService midtermService,
    required AuthService authService,
  })  : _authService = authService,
        _midtermService = midtermService {
    load = Command0<void>(_load)..execute();
    delete = Command1<void, int>(_delete);
  }

  factory MidtermsViewModel.create() => MidtermsViewModel(
        midtermService: MidtermsService.instance,
        authService: AuthService.instance,
      );

  final MidtermsService _midtermService;
  final AuthService _authService;
  late final Command0<void> load;
  late final Command1<void, int> delete;

  // State
  String _query = '';
  List<MidtermDate> _midterms = [];
  bool get canModerate => _authService.cachedUser?.canModerateMidterms ?? false;

  // Getters
  UnmodifiableListView<MidtermDate> get midterms =>
      UnmodifiableListView(_midterms);

  String get query => _query;
  void setQuery(String value) {
    _query = value;
    notifyListeners();
  }

  List<MidtermDate> get filteredMidterms {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return midterms;
    return midterms
        .where((m) =>
            m.subject.name.toLowerCase().contains(q) ||
            m.subject.code.toLowerCase().contains(q) ||
            (m.location?.toLowerCase().contains(q) ?? false))
        .toList();
  }

  bool get initialLoading => load.running && _midterms.isEmpty;

  Future<Result<void>> _load() async {
    final result = await _midtermService.getMidterms();

    switch (result) {
      case Ok(:final value):
        _midterms = value;
        notifyListeners();
        return const Ok(null);
      case Err(:final message):
        return Err(message);
    }
  }

  Future<Result<void>> _delete(int id) async {
    _midterms = _midterms.where((m) => m.id != id).toList();
    notifyListeners();
    final result = await _midtermService.deleteMidterm(midtermId: id);
    if (result is Err) await _load();
    return result;
  }
}
