import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:itk_app/data/repositories/auth_repository.dart';
import 'package:itk_app/data/repositories/wiki_sites_repository.dart';
import 'package:itk_app/domain/models/site_color.dart';
import 'package:itk_app/domain/models/user_site.dart';
import 'package:itk_app/utils/command.dart';
import 'package:itk_app/utils/result.dart';

class MySiteViewModel extends ChangeNotifier {
  MySiteViewModel({
    required WikiSitesRepository wikiSitesRepository,
    required AuthRepository authRepository,
  })  : _wikiSitesRepository = wikiSitesRepository,
        _authRepository = authRepository {
    // Start from the repository cache, like WikiViewModel does.
    // The wiki screen already loaded my site, so it is usually here.
    // Without this the first frame shows the defaults below (blue color, no tags)
    // until _load finishes, and the hero flies with the wrong color.
    // `?.value`: the site if it is cached, otherwise null.
    final cached = wikiSitesRepository.cachedMySite?.value;
    if (cached != null) {
      _tags = List.of(cached.tags);
      _hasExistingSite = true;
      _isPublic = cached.isPublic;
      _color = cached.color;
    }

    // Still refresh from the server; _load overwrites the cached values.
    load = Command0<void>(_load)..addListener(notifyListeners);
    unawaited(load.execute());
    save = Command0<void>(_save)..addListener(notifyListeners);
    delete = Command0<void>(_delete)..addListener(notifyListeners);
  }

  final WikiSitesRepository _wikiSitesRepository;
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
  // Defaults for "no site yet". The constructor overwrites them from the
  // cache, _load from the server. They need a value here because the
  // constructor body runs after the fields are created.
  List<String> _tags = [];
  bool _isPublic = true;
  bool _hasExistingSite = false;
  SiteColor _color = SiteColor.fallback;

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

  SiteColor get color => _color;
  void setColor(SiteColor color) {
    _color = color;
    notifyListeners();
  }

  // Methods
  Future<Result<void>> _load() async {
    // Mysite
    final result = await _wikiSitesRepository.get();

    if (result case Ok(value: final UserSite site)) {
      _tags = List.of(site.tags);
      _hasExistingSite = true;
      _isPublic = site.isPublic;
      _color = site.color;
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

    final result = await _wikiSitesRepository.save(_tags, _isPublic, _color);

    return result;
  }

  Future<Result<void>> _delete() async {
    final result = await _wikiSitesRepository.delete();
    return result;
  }
}
