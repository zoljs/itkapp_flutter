import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:itk_app/data/services/api_client.dart';
import 'package:itk_app/data/services/api_error.dart';
import 'package:itk_app/domain/models/user_site.dart';
import 'package:itk_app/utils/result.dart';

class SitesService {
  SitesService.internal();
  static final SitesService instance = SitesService.internal();

  final Dio _dio = ApiClient.instance.dio;
  final ValueNotifier<UserSite?> mySiteNotifier = ValueNotifier(null);

  // static const _legacyWikiUrl =
  //     'https://users.itk.ppke.hu/~perpa4/data/students.php';

  List<UserSite>? _cachedSites;
  List<UserSite> get cachedSites => _cachedSites ?? const [];
  bool get hasCachedSites => _cachedSites != null;
  void clearCache() => _cachedSites = null;

  Future<Result<List<UserSite>>> getAllSites({bool forceReload = false}) async {
    final cached = _cachedSites;
    if (cached != null && !forceReload) return Ok(cached);

    final Response<dynamic> response;
    try {
      response = await _dio.get('/api/sites');
    } on DioException catch (e) {
      return Err(apiErrorMessage(e));
    }

    final sites = _parseSites(response.data);
    if (sites == null) {
      return const Err('Nem sikerült feldolgozni az oldalakat.');
    }

    //sites.addAll(await _fetchLegacySites());
    _cachedSites = sites;
    return Ok(sites);
  }

  Future<Result<UserSite?>> getMySite() async {
    final Response<dynamic> response;
    try {
      response = await _dio.get('/api/sites/me');
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return _setMySite(null);
      return Err(apiErrorMessage(e));
    }

    final data = response.data;
    if (data is! Map<String, dynamic>) return _setMySite(null);
    final site = _parseSite(data);
    if (site == null) return const Err('Nem sikerült feldolgozni az oldalad.');
    return _setMySite(site);
  }

  Future<Result<UserSite>> saveMySite(List<String> tags) async {
    final Response<dynamic> response;
    try {
      response = await _dio.post('/api/sites', data: {'tags': tags});
    } on DioException catch (e) {
      return Err(apiErrorMessage(e));
    }

    final data = response.data;
    final saved = data is Map<String, dynamic> ? _parseSite(data) : null;
    if (saved == null) return const Err('Nem sikerült feldolgozni a választ.');

    mySiteNotifier.value = saved;
    clearCache();
    return Ok(saved);
  }

  Future<Result<void>> deleteMySite() async {
    try {
      await _dio.delete('/api/sites');
    } on DioException catch (e) {
      return Err(apiErrorMessage(e));
    }
    mySiteNotifier.value = null;
    clearCache();
    return const Ok(null);
  }

  Ok<UserSite?> _setMySite(UserSite? site) {
    mySiteNotifier.value = site;
    return Ok(site);
  }

  UserSite? _parseSite(Map<String, dynamic> json) {
    try {
      return UserSite.fromJson(json);
    } catch (e) {
      debugPrint('[SitesService] bad site json: $e');
      return null;
    }
  }

  List<UserSite>? _parseSites(Object? data) {
    if (data is! List) return null;
    final sites = <UserSite>[];
    for (final item in data) {
      if (item is! Map<String, dynamic>) return null;
      final site = _parseSite(item);
      if (site == null) return null;
      sites.add(site);
    }
    return sites;
  }

  // Future<List<UserSite>> _fetchLegacySites() async {
  //   try {
  //     final response = await Dio().get(_legacyWikiUrl);
  //     return _parseSites(response.data) ?? const [];
  //   } on DioException catch (e) {
  //     debugPrint('[SitesService] legacy wiki unavailable: ${e.message}');
  //     return const [];
  //   }
  // }
}
