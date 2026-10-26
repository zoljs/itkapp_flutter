import 'package:dio/dio.dart';
import 'package:itk_app/data/services/api_client.dart';
import 'package:itk_app/data/services/api_error.dart';
import 'package:itk_app/domain/models/subject.dart';
import 'package:itk_app/utils/result.dart';

class SubjectsRepository {
  SubjectsRepository({
    required ApiClient apiClient,
  }) : _dio = apiClient.dio;

  static final instance = SubjectsRepository(apiClient: ApiClient.instance);
  final Dio _dio;

  List<Subject>? _cached;

  void clearCache() => _cached = null;

  Future<Result<List<Subject>>> getSubjects({bool forceReload = false}) async {
    final cached = _cached;
    if (cached != null && !forceReload) return Ok(cached);

    try {
      final response = await _dio.get('/api/subjects');
      final subjects = parseSubjects(response.data);
      _cached = subjects;
      return Ok(subjects);
    } on DioException catch (e) {
      return Err(apiErrorMessage(e));
    } on FormatException catch (e) {
      return Err(e.message);
    }
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
