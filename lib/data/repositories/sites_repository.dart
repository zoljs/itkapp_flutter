import 'package:dio/dio.dart';
import 'package:itk_app/data/services/api_client.dart';
import 'package:itk_app/data/services/api_error.dart';
import 'package:itk_app/data/services/send_request.dart';
import 'package:itk_app/domain/models/user_site.dart';
import 'package:itk_app/utils/result.dart';

class SitesRepository {
  static const _path = '/api/sites';

  SitesRepository({
    required ApiClient apiClient,
  })  : _dio = apiClient.dio,
        _apiClient = apiClient;

  final Dio _dio;
  final ApiClient _apiClient;

  List<UserSite>? _cached;

  List<UserSite> get cached => _cached ?? const [];

  void clearCache() => _cached = null;

  Future<Result<List<UserSite>>> getAll({bool forceReload = false}) async {
    final cached = _cached;
    if (cached != null && !forceReload) return Ok(cached);

    final result = await _apiClient.getJson(_path, parse: UserSite.parseList);
    if (result case Ok(:final value)) _cached = value;
    return result;
  }

  Future<Result<UserSite?>> get() async {
    final Response<dynamic> response;
    try {
      response = await _dio.get('$_path/me');
      final data = response.data;
      if (data is! Map<String, dynamic>) return const Ok(null);
      return Ok(UserSite.fromJson(data));
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return const Ok(null);
      return Err(apiErrorMessage(e));
    } on FormatException catch (e) {
      return Err(e.message);
    }
  }

  Future<Result<UserSite>> save(List<String> tags, bool isPublic, bool isPhpEnabled) async {
    final result = await sendRequest(
      parse: UserSite.parse,
      send: () => _dio.post(_path, data: {'tags': tags, 'isPublic': isPublic, 'isPhpEnabled': isPhpEnabled}),
    );
    if (result is Ok) clearCache();

    return result;
  }

  Future<Result<void>> delete() async {
    final result = await sendRequest(parse: (_) {}, send: () => _dio.delete(_path));
    if (result is Ok) clearCache();
    return result;
  }
}
