import 'package:dio/dio.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:itk_app/data/services/send_request.dart';
import 'package:itk_app/utils/result.dart';
import 'package:path_provider/path_provider.dart';

class ApiClient {
  ApiClient._(this.dio, this._cookieJar) {
    // 401 Interceptor
    dio.interceptors.add(InterceptorsWrapper(
      onError: (error, handler) {
        if (isSessionExpired(error.requestOptions.uri, error.response?.statusCode)) {
          _handleUnauthorized();
        }
        handler.next(error);
      },
    ));

    // Session expired Interceptor
    dio.interceptors.add(InterceptorsWrapper(
      onResponse: (response, handler) {
        if (isSessionExpired(response.requestOptions.uri, response.statusCode)) {
          _handleUnauthorized();
          return handler.reject(DioException.badResponse(
            statusCode: 401,
            requestOptions: response.requestOptions,
            response: response,
          ));
        }
        handler.next(response);
      },
    ));
  }

  static const String baseUrl = 'https://test.app.itk.ppke.hu';

  final Dio dio;
  final CookieJar _cookieJar;

  Future<void> Function()? onUnauthorized;
  bool _handlingUnauthorized = false;

  Future<void> _handleUnauthorized() async {
    if (_handlingUnauthorized) return;
    _handlingUnauthorized = true;

    try {
      await onUnauthorized?.call();
    } finally {
      _handlingUnauthorized = false;
    }
  }

  static Future<ApiClient> create() async {
    final Dio dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        baseUrl: baseUrl,
      ),
    );
    final CookieJar cookieJar;

    final appDocDir = await getApplicationDocumentsDirectory();
    cookieJar = PersistCookieJar(
      storage: FileStorage('${appDocDir.path}/.cookies/'),
    );
    dio.interceptors.add(CookieManager(cookieJar));

    return ApiClient._(dio, cookieJar);
  }

  Future<void> clearCookies() async {
    await _cookieJar.deleteAll();
  }

  Future<Result<T>> getJson<T>(
    String path, {
    required T Function(Object?) parse,
    Map<String, dynamic>? queryParameters,
  }) async {
    return sendRequest(parse: parse, send: () => dio.get(path, queryParameters: queryParameters));
  }
}

const _pathsWithoutLogout = {'/api/auth/login', '/api/auth/logout'};
bool isSessionExpired(Uri uri, int? statusCode) => statusCode == 401 && uri.host == Uri.parse(ApiClient.baseUrl).host && !_pathsWithoutLogout.contains(uri.path);
