import 'package:dio/dio.dart';
import 'package:itk_app/data/services/api_client.dart';
import 'package:itk_app/data/services/api_error.dart';
import 'package:itk_app/domain/models/subject.dart';
import 'package:itk_app/utils/result.dart';

class SubjectsService {
  SubjectsService._();
  static final SubjectsService instance = SubjectsService._();
  static const _url = 'https://space.itk.ppke.hu/api/subjects';

  List<Subject>? _cached;

  Future<Result<List<Subject>>> getSubjects({bool forceReload = false}) async {
    final cached = _cached;
    if (cached != null && !forceReload) return Ok(cached);

    try {
      final response = await ApiClient.instance.dio.get(_url);
      final subjects = parseSubjects(response.data);
      _cached = subjects;
      return Ok(subjects);
    } on DioException catch (e) {
      return Err(apiErrorMessage(e));
    } on FormatException catch (e) {
      return Err(e.message);
    }
  }

  List<Subject> parseSubjects(Object? data) {
    if (data is! List) {
      throw const FormatException('A tárgylista nem lista formátumú.');
    }

    final subjects = <Subject>[];
    for (final entry in data) {
      if (entry is! Map<String, dynamic>) {
        throw const FormatException('Egy tárgy nem objektum formátumú.');
      }
      final name = entry['name'];
      final semester = entry['semester'];
      if (name is! String || name.trim().isEmpty) {
        throw const FormatException('Egy tárgynak hiányzik a neve.');
      }
      if (semester is! String) {
        throw FormatException('A(z) "$name" tárgynak hiányzik a féléve.');
      }
      subjects.add(Subject(name: name, semester: semester));
    }

    subjects.sort((a, b) => a.name.compareTo(b.name));
    return List.unmodifiable(subjects);
  }
}
