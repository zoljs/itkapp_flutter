import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:itk_app/data/repositories/auth_repository.dart';
import 'package:itk_app/data/repositories/sites_repository.dart';
import 'package:itk_app/domain/models/user_site.dart';
import 'package:itk_app/utils/command.dart';
import 'package:itk_app/utils/result.dart';

class MySiteViewModel extends ChangeNotifier {
  MySiteViewModel({
    required SitesRepository sitesRepository,
    required AuthRepository authRepository,
  })  : _sitesRepository = sitesRepository,
        _authRepository = authRepository {
    load = Command0<void>(_load)..execute();
    save = Command0<void>(_save);
    delete = Command0<void>(_delete);
  }

  final SitesRepository _sitesRepository;
  final AuthRepository _authRepository;
  late final Command0<void> load;
  late final Command0<void> save;
  late final Command0<void> delete;

  @override
  void dispose() {
    load.dispose();
    save.dispose();
    delete.dispose();
    super.dispose();
  }

  // State
  List<String> _tags = [];
  bool _isPublic = true;
  bool _isPhpEnabled = false;
  bool _hasExistingSite = false;

  // Getters
  UnmodifiableListView<String> get tags => UnmodifiableListView(_tags);
  void setTags(List<String> value) {
    _tags = value;
    notifyListeners();
  }

  bool get hasExistingSite => _hasExistingSite;
  String? get login => _authRepository.cachedUser?.login;

  bool get isPublic => _isPublic;
  void setPublic(bool value) {
    _isPublic = value;
    notifyListeners();
  }

  bool get isPhpEnabled => _isPhpEnabled;
  void setPhpEnabled(bool value) {
    _isPhpEnabled = value;
    notifyListeners();
  }

  // Methods
  Future<Result<void>> _load() async {
    // Mysite
    final result = await _sitesRepository.getMySite();

    if (result case Ok(value: final UserSite site)) {
      _tags = List.of(site.tags);
      _hasExistingSite = true;
      _isPublic = site.isPublic;
      _isPhpEnabled = site.isPhpEnabled;
      notifyListeners();
    } else if (result case Ok(value: null)) {
      _hasExistingSite = false;
      notifyListeners();
    }
    return result;
  }

  Future<Result<void>> _save() async {
    if (_authRepository.cachedUser == null) {
      return const Err('Nincs bejelentkezett felhasználó.');
    }

    final result =
        await _sitesRepository.saveMySite(_tags, _isPublic, _isPhpEnabled);

    return result;
  }

  Future<Result<void>> _delete() async {
    final result = await _sitesRepository.deleteMySite();
    return result;
  }
}
