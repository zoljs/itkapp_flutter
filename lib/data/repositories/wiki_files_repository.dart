import 'package:dio/dio.dart';
import 'package:itk_app/data/services/api_client.dart';
import 'package:itk_app/data/services/api_error.dart';
import 'package:itk_app/domain/models/wiki_file.dart';
import 'package:itk_app/utils/result.dart';

class WikiFilesRepository {
  WikiFilesRepository({
    required ApiClient apiClient,
  }) : _dio = apiClient.dio;

  static final instance = WikiFilesRepository(apiClient: ApiClient.instance);
  final Dio _dio;

  Future<Result<List<WikiFile>>> listDir(String dir) async {
    try {
      final response = await _dio.get(
        '/perpa4/files.php',
        queryParameters: {'dir': dir},
      );
      return Ok(parseFiles(response.data));
    } on DioException catch (e) {
      return Err(apiErrorMessage(e));
    } on FormatException catch (e) {
      return Err(e.message);
    }
  }

  static List<WikiFile> parseFiles(Object? data) {
    if (data is! List) {
      throw const FormatException('A fájllista nem lista formátumú.');
    }

    final files = <WikiFile>[];
    for (final entry in data) {
      if (entry is! Map<String, dynamic>) {
        throw const FormatException('Egy fájlnév nem szöveg.');
      }
      files.add(WikiFile.fromJson(entry));
    }
    return List.unmodifiable(files);
  }
}
