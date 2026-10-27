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

    final result =
        await _apiClient.getJson('/api/subjects', parse: parseSubjects);
    if (result case Ok(:final value)) _cached = value;
    return result;
  }

  static List<Subject> parseSubjects(Object? data) {
    if (data is! List) {
      throw const FormatException('A tárgylista nem lista formátumú.');
    }

    final subjects = <Subject>[];
    for (final entry in data) {
      if (entry is! Map<String, dynamic>) {
        throw const FormatException('Egy tárgy nem objektum formátumú.');
      }
      subjects.add(Subject.fromJson(entry));
    }
    return List.unmodifiable(subjects);
  }
}
