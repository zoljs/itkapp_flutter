import 'package:dio/dio.dart';
import 'package:itk_app/data/services/send_request.dart';
import 'package:itk_app/utils/result.dart';

class UsersClient {
  UsersClient()
      : dio = Dio(BaseOptions(
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
          baseUrl: baseUrl,
        ));

  final Dio dio;
  static const String baseUrl = 'https://users.itk.ppke.hu';

  Future<Result<T>> getJson<T>(
    String path, {
    required T Function(Object?) parse,
    Map<String, dynamic>? queryParameters,
  }) async {
    return sendRequest(parse: parse, send: () => dio.get(path, queryParameters: queryParameters));
  }
}
