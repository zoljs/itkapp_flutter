import 'package:dio/dio.dart';
import 'package:itk_app/data/services/api_client.dart';
import 'package:itk_app/data/services/send_request.dart';
import 'package:itk_app/domain/models/user_summary.dart';
import 'package:itk_app/utils/result.dart';

class AdminRolesRepository {
  AdminRolesRepository({
    required ApiClient apiClient,
  })  : _dio = apiClient.dio,
        _apiClient = apiClient;

  final Dio _dio;
  final ApiClient _apiClient;

  Future<Result<List<UserSummary>>> getRoleHolders() async => await _apiClient.getJson('/api/admin/roles', parse: UserSummary.parseUsers);

  Future<Result<void>> assignCohortRep(int userId) async {
    final result = await sendRequest(
        parse: (_) {},
        send: () => _dio.post(
              '/api/admin/roles',
              data: {
                'userId': userId,
                'role': 'COHORT_REP',
              },
            ));
    return result;
  }

  Future<Result<void>> revokeRole(int userId) async {
    final result = await sendRequest(parse: (_) {}, send: () => _dio.delete('/api/admin/roles/$userId'));
    return result;
  }
}
