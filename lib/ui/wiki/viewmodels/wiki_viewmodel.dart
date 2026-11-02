import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:itk_app/data/repositories/sites_repository.dart';
import 'package:itk_app/data/repositories/wiki_files_repository.dart';
import 'package:itk_app/domain/models/user_site.dart';
import 'package:itk_app/utils/command.dart';
import 'package:itk_app/utils/result.dart';

class WikiViewModel extends ChangeNotifier {
  WikiViewModel({
    required SitesRepository sitesRepository,
    required WikiFilesRepository wikiFilesRepository,
  })  : _sitesRepository = sitesRepository,
        _wikiFilesRepository = wikiFilesRepository,
        _sites = sitesRepository.cached {
    load = Command1<void, bool>(_load);
    unawaited(load.execute(false));
  }

  final SitesRepository _sitesRepository;
  final WikiFilesRepository _wikiFilesRepository;

  // State
  List<UserSite> _sites;
  late final Command1<void, bool> load;
  UserSite? _mySite;
  String _query = '';

  @override
  void dispose() {
    load.dispose();
    super.dispose();
  }

  // Getters
  UnmodifiableListView<UserSite> get sites => UnmodifiableListView(_sites);
  UserSite? get mySite => _mySite;
  String get query => _query;

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
      _sitesRepository.getAll(forceReload: forceReload),
      _sitesRepository.get(),
    ).wait;

    // mySite
    if (mySiteResult case Ok(:final value)) _mySite = value;

    if (sitesResult case Ok(:final value)) {
      _sites = value;
      notifyListeners();
    }
    return sitesResult;
  }

  Future<bool> hasFileList(String user) async {
    final result = await _wikiFilesRepository.listDir('', user);
    return result is Ok;
  }

  void setQuery(String value) {
    _query = value;
    notifyListeners();
  }
}
