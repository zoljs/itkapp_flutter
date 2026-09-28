import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../domain/models/user_site.dart';
import 'api_client.dart';

class SitesService {
  SitesService.internal();
  static final SitesService instance = SitesService.internal();

  final Dio _dio = ApiClient.instance.dio;
  final ValueNotifier<UserSite?> mySiteNotifier = ValueNotifier(null);
  final searchQuery = ValueNotifier<String>('');

  static const _legacyWikiUrl =
      'https://users.itk.ppke.hu/~perpa4/data/students.php';

  // Cache of all sites
  List<UserSite> _cachedSites = [];
  List<UserSite> get cachedSites => List.unmodifiable(_cachedSites);
  bool get hasCachedSites => _cachedSites.isNotEmpty;
  void clearCache() => _cachedSites.clear();

  // Returns the cache, if empty: sets the result of the GET request as the cache then returns it
  Future<List<UserSite>> getAllSites({bool forceReload = false}) async {
    if (_cachedSites.isNotEmpty && forceReload == false) {
      return _cachedSites;
    }

    final response = await _dio.get('/api/sites');
    final data = response.data as List;
    final sites = data
        .map((json) => UserSite.fromJson(json as Map<String, dynamic>))
        .toList();

    try {
      final legacyResponse = await Dio().get(_legacyWikiUrl);

      if (legacyResponse.statusCode == 200 && legacyResponse.data is List) {
        final legacySites = (legacyResponse.data as List).map((json) {
          return UserSite.fromJson(json as Map<String, dynamic>);
        }).toList();
        sites.addAll(legacySites);
      }
    } catch (_) {}

    _cachedSites = sites;
    return _cachedSites;
  }

  // Get the users site only, e.g. the settings page
  Future<UserSite?> getMySite() async {
    final response = await _dio.get('/api/sites/me');
    final data = response.data;
    if (data is Map) {
      final fetchedSite = UserSite.fromJson(data as Map<String, dynamic>);
      mySiteNotifier.value = fetchedSite;
      return fetchedSite;
    }
    return null;
  }

  // Saves the users site and clears the cache for automatic reload on pages
  Future<UserSite> saveMySite(UserSite site) async {
    final requestBody = site.toJson();
    final response = await _dio.post('/api/sites', data: requestBody);

    if (response.statusCode != 200) {
      throw DioException(
          requestOptions: response.requestOptions, response: response);
    }

    final data = response.data;
    final userSite = UserSite.fromJson(data as Map<String, dynamic>);
    mySiteNotifier.value = userSite;

    clearCache();

    return userSite;
  }

  // Deletes the users site and clears the cache for automatic reload on pages
  Future<void> deleteMySite() async {
    await _dio.delete('/api/sites');
    mySiteNotifier.value = null;
    clearCache();
  }
}
