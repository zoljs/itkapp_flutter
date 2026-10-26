import 'package:dio/dio.dart';
import 'package:itk_app/data/services/api_client.dart';
import 'package:itk_app/domain/models/online_video.dart';

class VideosService {
  VideosService._();
  static final VideosService instance = VideosService._();

  static const pageSize = 50;

  Dio get _dio => ApiClient.instance.dio;

  final Map<String, VideoFilters> _filtersCache = {};

  Map<String, dynamic> _params({
    String? semester,
    String? subject,
    String? query,
  }) =>
      {
        if (semester != null) 'semester': semester,
        if (subject != null) 'subject': subject,
        if (query != null && query.trim().isNotEmpty) 'q': query.trim(),
      };

  Future<VideoFilters> getFilters({
    String? semester,
    String? subject,
    bool forceReload = false,
  }) async {
    final key = '${semester ?? ''}|${subject ?? ''}';
    final cached = _filtersCache[key];
    if (cached != null && !forceReload) return cached;

    final response = await _dio.get(
      '/api/videos/filters',
      queryParameters: _params(semester: semester, subject: subject),
    );
    _ensureOk(response);
    final filters =
        VideoFilters.fromJson(response.data as Map<String, dynamic>);
    _filtersCache[key] = filters;
    return filters;
  }

  Future<VideoPage> getVideos({
    String? semester,
    String? subject,
    String? query,
    int offset = 0,
    int limit = pageSize,
  }) async {
    final response = await _dio.get(
      '/api/videos',
      queryParameters: {
        ..._params(semester: semester, subject: subject, query: query),
        'offset': offset,
        'limit': limit,
      },
    );
    _ensureOk(response);
    return VideoPage.fromJson(response.data as Map<String, dynamic>);
  }

  void _ensureOk(Response response) {
    if (response.statusCode != 200 || response.data is! Map) {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        type: DioExceptionType.badResponse,
      );
    }
  }

  void clearCache() => _filtersCache.clear();
}
