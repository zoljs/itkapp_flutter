import 'package:dio/dio.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:dio_web_adapter/dio_web_adapter.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

class ApiClient {
  ApiClient._internal();
  static final ApiClient instance = ApiClient._internal();

  static const String baseUrl = 'https://test.app.itk.ppke.hu';

  late final Dio dio;
  CookieJar? _cookieJar;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        validateStatus: (status) => status != null && status < 500,
      ),
    );

    if (kIsWeb) {
    // Cross-origin XHR needs this explicitly, otherwise the browser
    // drops the session cookie from the login response entirely.
    dio.httpClientAdapter = BrowserHttpClientAdapter(withCredentials: true);
    } else {
      // dio_cookie_manager asserts against being used on web; only wire
      // up the file-based cookie jar on other platforms.
      final appDocDir = await getApplicationDocumentsDirectory();
      _cookieJar = PersistCookieJar(
        storage: FileStorage('${appDocDir.path}/.cookies/'),
      );
      dio.interceptors.add(CookieManager(_cookieJar!));
    }
    _initialized = true;
  }

  Future<void> clearCookies() async {
    await _cookieJar?.deleteAll();
  }
}
