import 'package:dio/dio.dart';
import '../models/user_site.dart';
import 'api_client.dart';

class SitesService {
  SitesService.internal();
  static final SitesService instance = SitesService.internal();

  final Dio _dio = ApiClient.instance.dio;

  static const _legacyWikiUrl =
      'https://users.itk.ppke.hu/~perpa4/data/students.php';

  List<UserSite> _cachedSites = [];

  bool get hasCachedSites => _cachedSites.isNotEmpty;

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

  Future<UserSite?> getMySite() async {
    final response = await _dio.get('/api/sites/me');
    final data = response.data;
    if (data is Map) {
      return UserSite.fromJson(data as Map<String, dynamic>);
    }
    return null;
  }

  Future<UserSite> saveMySite(UserSite site) async {
    final requestBody = site.toJson();
    final response = await _dio.post('/api/sites', data: requestBody);

    if (response.statusCode != 200) {
      throw DioException(
          requestOptions: response.requestOptions, response: response);
    }

    final responseData = response.data;
    final userSite = UserSite.fromJson(responseData as Map<String, dynamic>);

    _cachedSites.clear();

    return userSite;
  }

  Future<void> deleteMySite() async {
    await _dio.delete('/api/sites');
    _cachedSites.clear();
  }

  void clearCache() {
    _cachedSites.clear();
  }

  List<UserSite> get cachedSites => List.unmodifiable(_cachedSites);
}
