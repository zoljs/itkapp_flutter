import 'package:itk_app/data/services/api_client.dart';
import 'package:itk_app/domain/models/user_summary.dart';
import 'package:itk_app/utils/result.dart';

class AdminRolesRepository {
  static const _path = '/api/admin/roles';

  AdminRolesRepository({
    required ApiClient apiClient,
  }) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<Result<List<UserSummary>>> getRoleHolders() async =>
      _apiClient.getJson(_path, parse: UserSummary.parseList);

  Future<Result<void>> assignCohortRep(int userId) async {
    final result = await _apiClient.post(
      _path,
      data: {
        'userId': userId,
        'role': 'COHORT_REP',
      },
    );
    return result;
  }

  Future<Result<void>> revokeRole(int userId) async {
    final result = await _apiClient.delete('$_path/$userId');
    return result;
  }
}
