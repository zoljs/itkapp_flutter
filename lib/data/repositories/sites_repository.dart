import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:itk_app/data/services/api_client.dart';
import 'package:itk_app/data/services/api_error.dart';
import 'package:itk_app/domain/models/user_site.dart';
import 'package:itk_app/utils/result.dart';

class SitesRepository {
  SitesRepository({
    required ApiClient apiClient,
  }) : _dio = apiClient.dio;

  final Dio _dio;

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

    _cachedSites = sites;
    return Ok(sites);
  }

  Future<Result<UserSite?>> getMySite() async {
    final Response<dynamic> response;
    try {
      response = await _dio.get('/api/sites/me');
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return const Ok(null);
      return Err(apiErrorMessage(e));
    }

    final data = response.data;
    if (data is! Map<String, dynamic>) return const Ok(null);
    final site = _parseSite(data);
    if (site == null) return const Err('Nem sikerült feldolgozni az oldalad.');
    return Ok(site);
  }

  Future<Result<UserSite>> saveMySite(
      List<String> tags, bool isPublic, bool isPhpEnabled) async {
    final Response<dynamic> response;
    try {
      response = await _dio.post('/api/sites', data: {
        'tags': tags,
        'isPublic': isPublic,
        'isPhpEnabled': isPhpEnabled
      });
    } on DioException catch (e) {
      return Err(apiErrorMessage(e));
    }

    final data = response.data;
    final saved = data is Map<String, dynamic> ? _parseSite(data) : null;
    if (saved == null) return const Err('Nem sikerült feldolgozni a választ.');

    clearCache();
    return Ok(saved);
  }

  Future<Result<void>> deleteMySite() async {
    try {
      await _dio.delete('/api/sites');
    } on DioException catch (e) {
      return Err(apiErrorMessage(e));
    }
    clearCache();
    return const Ok(null);
  }

  UserSite? _parseSite(Map<String, dynamic> json) {
    try {
      return UserSite.fromJson(json);
    } catch (e) {
      debugPrint('[SitesRepository] bad site json: $e');
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
}
