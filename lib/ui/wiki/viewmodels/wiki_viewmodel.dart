import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:itk_app/data/repositories/sites_repository.dart';
import 'package:itk_app/domain/models/user_site.dart';
import 'package:itk_app/utils/command.dart';
import 'package:itk_app/utils/result.dart';

class WikiViewModel extends ChangeNotifier {
  WikiViewModel({
    required SitesRepository service,
  })  : _service = service,
        _sites = service.cachedSites {
    load = Command1<void, bool>(_load)..execute(false);
  }

  factory WikiViewModel.create() =>
      WikiViewModel(service: SitesRepository.instance);

  final SitesRepository _service;

  // State
  List<UserSite> _sites;
  late final Command1<void, bool> load;
  UserSite? _mySite;
  String _query = '';

  // Getters
  UnmodifiableListView<UserSite> get sites => UnmodifiableListView(_sites);
  UserSite? get mySite => _mySite;
  String get query => _query;

  List<UserSite> get filteredSites {
    final q = _query.trim().toLowerCase();

    return _sites.where((s) {
      final matchesSearch = q.isEmpty ||
          s.name.toLowerCase().contains(q) ||
          s.tags.any((t) => t.toLowerCase().contains(q)) ||
          s.url.toLowerCase().contains(q);

      return matchesSearch;
    }).toList();
  }

  // Methods
  Future<Result<void>> _load(bool forceReload) async {
    final (sitesResult, mySiteResult) = await (
      _service.getAllSites(forceReload: forceReload),
      _service.getMySite(),
    ).wait;

    // mySite
    if (mySiteResult case Ok(:final value)) _mySite = value;

    switch (sitesResult) {
      case Ok(:final value):
        _sites = value;
        notifyListeners();
        return const Ok(null);
      case Err(:final message):
        return Err(message);
    }
  }

  void setQuery(String value) {
    _query = value;
    notifyListeners();
  }
}
