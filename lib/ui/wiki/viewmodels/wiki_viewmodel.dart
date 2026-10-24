import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:itk_app/data/services/sites_service.dart';
import 'package:itk_app/domain/models/user_site.dart';
import 'package:itk_app/utils/result.dart';

class WikiViewModel extends ChangeNotifier {
  WikiViewModel({
    required SitesService service,
  })  : _service = service,
        _sites = service.cachedSites,
        _loading = !service.hasCachedSites;

  factory WikiViewModel.create() =>
      WikiViewModel(service: SitesService.instance);

  // State
  final SitesService _service;
  List<UserSite> _sites;
  bool _loading;

  UserSite? _mySite;
  String? _error;
  String _query = '';

  // Getters
  UnmodifiableListView<UserSite> get sites => UnmodifiableListView(_sites);
  UserSite? get mySite => _mySite;
  bool get loading => _loading;
  String? get error => _error;
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
  Future<void> load({bool forceReload = false}) async {
    _error = null;
    if (!_service.hasCachedSites || forceReload) _loading = true;
    notifyListeners();

    final (sitesResult, mySiteResult) = await (
      _service.getAllSites(forceReload: forceReload),
      _service.getMySite(),
    ).wait;

    switch (sitesResult) {
      case Ok(:final value):
        _sites = value;
      case Err(:final message):
        _error = message;
    }
    if (mySiteResult case Ok(:final value)) _mySite = value;
    _loading = false;
    notifyListeners();
  }

  void setQuery(String value) {
    _query = value;
    notifyListeners();
  }
}
