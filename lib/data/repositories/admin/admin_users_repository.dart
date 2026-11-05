import 'package:itk_app/data/services/api_client.dart';
import 'package:itk_app/domain/models/user_summary.dart';
import 'package:itk_app/utils/result.dart';

class AdminUsersRepository {
  static const _path = '/api/admin/users';

  AdminUsersRepository({
    required ApiClient apiClient,
  }) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<Result<List<UserSummary>>> get() async =>
      _apiClient.getJson(_path, parse: UserSummary.parseList);
}
