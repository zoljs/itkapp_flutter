import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:itk_app/data/repositories/auth_repository.dart';
import 'package:itk_app/data/repositories/wiki_sites_repository.dart';
import 'package:itk_app/data/repositories/wiki_files_repository.dart';
import 'package:itk_app/domain/models/user_site.dart';
import 'package:itk_app/domain/models/wiki_file.dart';
import 'package:itk_app/utils/command.dart';
import 'package:itk_app/utils/result.dart';

class WikiViewModel extends ChangeNotifier {
  WikiViewModel({
    required WikiSitesRepository wikiSitesRepository,
    required WikiFilesRepository wikiFilesRepository,
    required AuthRepository authRepository,
  })  : _authRepository = authRepository,
        _wikiSitesRepository = wikiSitesRepository,
        _wikiFilesRepository = wikiFilesRepository,
        _sites = wikiSitesRepository.cachedSites,
        _mySite = wikiSitesRepository.cachedMySite {
    load = Command1<void, bool>(_load)..addListener(notifyListeners);
    checkFiles = Command1<List<WikiFile>, String>(_checkFiles)
      ..addListener(notifyListeners);
    unawaited(load.execute(false));
  }

  final WikiSitesRepository _wikiSitesRepository;
  final WikiFilesRepository _wikiFilesRepository;
  final AuthRepository _authRepository;

  // State
  List<UserSite> _sites;
  Ok<UserSite?>? _mySite;
  late final Command1<void, bool> load;
  late final Command1<List<WikiFile>, String> checkFiles;
  // Getter returns value while checkFiles.running; otherwise null.
  String? _checkingLogin;
  String _query = '';

  @override
  void dispose() {
    load.dispose();
    checkFiles.dispose();
    super.dispose();
  }

  // Getters
  UnmodifiableListView<UserSite> get sites => UnmodifiableListView(_sites);
  UserSite? get mySite => _mySite?.value;
  String get query => _query;
  String? get checkingLogin => checkFiles.running ? _checkingLogin : null;
  String? get login => _authRepository.cachedUser?.login;

  bool get sitesInitialLoading => load.running && _sites.isEmpty;
  bool get mySiteInitialLoading => load.running && _mySite == null;

  List<UserSite> get filteredSites {
    final q = _query.trim().toLowerCase();

    return _sites.where((s) {
      final myLogin = _mySite?.value?.login;
      final isMine = myLogin != null && s.login == myLogin;
      final matchesSearch = q.isEmpty ||
          s.name.toLowerCase().contains(q) ||
          s.tags.any((t) => t.toLowerCase().contains(q)) ||
          s.url.toLowerCase().contains(q);

      return !isMine && matchesSearch;
    }).toList();
  }

  // Methods
  Future<Result<void>> _load(bool forceReload) async {
    final sitesFuture = _wikiSitesRepository.getAll(forceReload: forceReload);

    final mySiteResult =
        await _wikiSitesRepository.get(forceReload: forceReload);
    if (mySiteResult is Ok<UserSite?>) {
      _mySite = mySiteResult;
      notifyListeners();
    }

    final sitesResult = await sitesFuture;

    if (sitesResult case Ok(:final value)) {
      _sites = value;
      notifyListeners();
    }
    return sitesResult;
  }

  Future<Result<List<WikiFile>>> _checkFiles(String login) async {
    _checkingLogin = login;
    return _wikiFilesRepository.listDir('', login);
  }

  void setQuery(String value) {
    _query = value;
    notifyListeners();
  }
}
