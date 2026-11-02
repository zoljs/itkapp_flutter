import 'package:itk_app/data/services/api_client.dart';
import 'package:itk_app/domain/models/user_site.dart';
import 'package:itk_app/utils/result.dart';

class WikiSitesRepository {
  static const _path = '/api/sites';

  WikiSitesRepository({
    required ApiClient apiClient,
  }) : _apiClient = apiClient;

  final ApiClient _apiClient;

  List<UserSite>? _cachedSites;
  Ok<UserSite?>? _cachedMySite;

  List<UserSite> get cachedSites => _cachedSites ?? const [];
  Ok<UserSite?>? get cachedMySite => _cachedMySite;

  void clearCache() {
    _cachedSites = null;
    _cachedMySite = null;
  }

  Future<Result<List<UserSite>>> getAll({bool forceReload = false}) async {
    final cachedSites = _cachedSites;
    if (cachedSites != null && !forceReload) return Ok(cachedSites);

    final result = await _apiClient.getJson(_path, parse: UserSite.parseList);
    if (result case Ok(:final value)) _cachedSites = value;
    return result;
  }

  Future<Result<UserSite?>> get({bool forceReload = false}) async {
    final cachedMySite = _cachedMySite;
    if (cachedMySite != null && !forceReload) return cachedMySite;

    final result = await _apiClient.getJson('$_path/me', parse: UserSite.parseOptional);
    if (result is Ok<UserSite?>) _cachedMySite = result;
    return result;
  }

  Future<Result<UserSite>> save(List<String> tags, bool isPublic) async {
    final result = await _apiClient.postJson(
      _path,
      parse: UserSite.parse,
      data: {'tags': tags, 'isPublic': isPublic},
    );
    if (result is Ok<UserSite>) {
      clearCache();
      _cachedMySite = result;
    }

    return result;
  }

  Future<Result<void>> delete() async {
    final result = await _apiClient.delete(_path);
    if (result is Ok) {
      clearCache();
      _cachedMySite = const Ok(null);
    }
    return result;
  }
}
