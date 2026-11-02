import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';
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
  })  : _wikiSitesRepository = wikiSitesRepository,
        _wikiFilesRepository = wikiFilesRepository,
        _sites = wikiSitesRepository.cachedSites,
        _mySite = wikiSitesRepository.cachedMySite {
    load = Command1<void, bool>(_load);
    checkFiles = Command1<List<WikiFile>, String>(_checkFiles);
    unawaited(load.execute(false));
  }

  final WikiSitesRepository _wikiSitesRepository;
  final WikiFilesRepository _wikiFilesRepository;

  // State
  List<UserSite> _sites;
  Ok<UserSite?>? _mySite;
  late final Command1<void, bool> load;
  late final Command1<List<WikiFile>, String> checkFiles;
  // Only meaningful while checkFiles.running; not cleared on purpose.
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
  String? get checkingLogin => _checkingLogin;

  bool get sitesInitialLoading => load.running && _sites.isEmpty;
  bool get mySiteInitialLoading => load.running && _mySite == null;

  List<UserSite> get filteredSites {
    final q = _query.trim().toLowerCase();

    return _sites.where((s) {
      final matchesSearch = q.isEmpty || s.name.toLowerCase().contains(q) || s.tags.any((t) => t.toLowerCase().contains(q)) || s.url.toLowerCase().contains(q);

      return matchesSearch;
    }).toList();
  }

  // Methods
  Future<Result<void>> _load(bool forceReload) async {
    final (sitesResult, mySiteResult) = await (
      _wikiSitesRepository.getAll(forceReload: forceReload),
      _wikiSitesRepository.get(forceReload: forceReload),
    ).wait;

    // mySite
    if (mySiteResult is Ok<UserSite?>) _mySite = mySiteResult;

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
