import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:itk_app/data/repositories/auth_repository.dart';
import 'package:itk_app/data/repositories/midterms_repository.dart';
import 'package:itk_app/domain/models/midterm_date.dart';
import 'package:itk_app/utils/command.dart';
import 'package:itk_app/utils/result.dart';

class MidtermsViewModel extends ChangeNotifier {
  MidtermsViewModel({
    required MidtermsRepository midtermRepository,
    required AuthRepository authRepository,
    repository,
  })  : _authRepository = authRepository,
        _midtermRepository = midtermRepository {
    load = Command1<void, bool>(_load)..execute(false);
    delete = Command1<void, int>(_delete);
  }

  final MidtermsRepository _midtermRepository;
  final AuthRepository _authRepository;
  late final Command1<void, bool> load;
  late final Command1<void, int> delete;

  @override
  void dispose() {
    load.dispose();
    delete.dispose();
    super.dispose();
  }

  // State
  String _query = '';
  List<MidtermDate> _midterms = [];
  bool get canModerate =>
      _authRepository.cachedUser?.canModerateMidterms ?? false;

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

  Future<Result<void>> _load(bool forceReload) async {
    final result =
        await _midtermRepository.getMidterms(forceReload: forceReload);

    if (result case Ok(:final value)) {
      _midterms = value;
      notifyListeners();
    }
    return result;
  }

  Future<Result<void>> _delete(int id) async {
    _midterms = _midterms.where((m) => m.id != id).toList();
    notifyListeners();
    final result = await _midtermRepository.deleteMidterm(midtermId: id);
    if (result is Err) await _load(true);
    return result;
  }
}
