import 'package:dio/dio.dart';
import 'package:itk_app/data/services/api_error.dart';
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
    try {
      final response = await dio.get(path, queryParameters: queryParameters);
      final value = parse(response.data);

      return Ok(value);
    } on DioException catch (e) {
      return Err(apiErrorMessage(e));
    } on FormatException catch (e) {
      return Err(e.message);
    }
  }
}
