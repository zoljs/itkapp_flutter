import 'package:dio/dio.dart';
import 'package:itk_app/data/services/api_client.dart';
import 'package:itk_app/data/services/api_error.dart';
import 'package:itk_app/domain/models/user_summary.dart';
import 'package:itk_app/utils/result.dart';

class AdminUsersRepository {
  AdminUsersRepository({
    required ApiClient apiClient,
  }) : _dio = apiClient.dio;

  static final instance = AdminUsersRepository(apiClient: ApiClient.instance);
  final Dio _dio;

  Future<Result<List<UserSummary>>> getUsers() async {
    try {
      final response = await _dio.get('/api/admin/users');
      final users = UserSummary.parseUsers(response.data);
      return Ok(users);
    } on DioException catch (e) {
      return Err(apiErrorMessage(e));
    } on FormatException catch (e) {
      return Err(e.message);
    }
  }
}
