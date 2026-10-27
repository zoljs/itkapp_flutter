import 'package:dio/dio.dart';
import 'package:itk_app/data/services/api_error.dart';
import 'package:itk_app/utils/result.dart';

Future<Result<T>> sendRequest<T>({
  required T Function(Object?) parse,
  required Future<Response<dynamic>> Function() send,
}) async {
  try {
    final response = await send();
    final value = parse(response.data);

    return Ok(value);
  } on DioException catch (e) {
    return Err(apiErrorMessage(e));
  } on FormatException catch (e) {
    return Err(e.message);
  }
}
