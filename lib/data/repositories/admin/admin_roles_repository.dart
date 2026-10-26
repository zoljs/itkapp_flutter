import 'package:dio/dio.dart';
import 'package:itk_app/data/services/api_client.dart';
import 'package:itk_app/data/services/api_error.dart';
import 'package:itk_app/domain/models/user_summary.dart';
import 'package:itk_app/utils/result.dart';

class AdminRolesRepository {
  AdminRolesRepository({
    required ApiClient apiClient,
  }) : _dio = apiClient.dio;

  final Dio _dio;

  Future<Result<List<UserSummary>>> getRoleHolders() async {
    try {
      final response = await _dio.get('/api/admin/roles');
      final users = UserSummary.parseUsers(response.data);
      return Ok(users);
    } on DioException catch (e) {
      return Err(apiErrorMessage(e));
    } on FormatException catch (e) {
      return Err(e.message);
    }
  }

  Future<Result<void>> assignCohortRep(int userId) async {
    try {
      await _dio.post(
        '/api/admin/roles',
        data: {
          'userId': userId,
          'role': 'COHORT_REP',
        },
      );
    } on DioException catch (e) {
      return Err(apiErrorMessage(e));
    }
    return const Ok(null);
  }

  Future<Result<void>> revokeRole(int userId) async {
    try {
      await _dio.delete('/api/admin/roles/$userId');
    } on DioException catch (e) {
      return Err(apiErrorMessage(e));
    }
    return const Ok(null);
  }
}
