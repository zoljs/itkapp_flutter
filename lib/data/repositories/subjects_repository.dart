import 'package:itk_app/data/services/api_client.dart';
import 'package:itk_app/domain/models/subject.dart';
import 'package:itk_app/utils/result.dart';

class SubjectsRepository {
  SubjectsRepository({
    required ApiClient apiClient,
  }) : _apiClient = apiClient;

  final ApiClient _apiClient;

  List<Subject>? _cached;

  void clearCache() => _cached = null;

  Future<Result<List<Subject>>> getSubjects({bool forceReload = false}) async {
    final cached = _cached;
    if (cached != null && !forceReload) return Ok(cached);

    final result = await _apiClient.getJson('/api/subjects', parse: Subject.parseList);
    if (result case Ok(:final value)) _cached = value;
    return result;
  }
}
