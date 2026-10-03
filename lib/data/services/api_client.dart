import 'package:dio/dio.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:itk_app/data/services/http_adapter.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

class ApiClient {
  ApiClient._internal();
  static final ApiClient instance = ApiClient._internal();

  static const String baseUrl = 'https://test.app.itk.ppke.hu';

  late final Dio dio;
  CookieJar? _cookieJar;
  bool _initialized = false;

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

  Future<void> init() async {
    if (_initialized) return;

    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    );

    if (kIsWeb) {
      configureHttpAdapter(dio);
    } else {
      final appDocDir = await getApplicationDocumentsDirectory();
      _cookieJar = PersistCookieJar(
        storage: FileStorage('${appDocDir.path}/.cookies/'),
      );
      dio.interceptors.add(CookieManager(_cookieJar!));
    }

    // 401 Interceptor
    dio.interceptors.add(InterceptorsWrapper(
      onError: (error, handler) {
        if (isSessionExpired(
            error.requestOptions.uri, error.response?.statusCode)) {
          _handleUnauthorized();
        }
        handler.next(error);
      },
    ));

    // Session expired Interceptor
    dio.interceptors.add(InterceptorsWrapper(
      onResponse: (response, handler) {
        if (isSessionExpired(
            response.requestOptions.uri, response.statusCode)) {
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

    _initialized = true;
  }

  Future<void> clearCookies() async {
    await _cookieJar?.deleteAll();
  }
}

const _pathsWithoutLogout = {'/api/auth/login', '/api/auth/logout'};
bool isSessionExpired(Uri uri, int? statusCode) =>
    statusCode == 401 &&
    uri.host == Uri.parse(ApiClient.baseUrl).host &&
    !_pathsWithoutLogout.contains(uri.path);
