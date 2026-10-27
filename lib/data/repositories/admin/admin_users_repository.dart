import 'package:itk_app/data/services/api_client.dart';
import 'package:itk_app/domain/models/user_summary.dart';
import 'package:itk_app/utils/result.dart';

class AdminUsersRepository {
  AdminUsersRepository({
    required ApiClient apiClient,
  }) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<Result<List<UserSummary>>> getUsers() async => await _apiClient.getJson('/api/admin/users', parse: UserSummary.parseUsers);
}
