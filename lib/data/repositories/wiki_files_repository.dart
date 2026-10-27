import 'package:itk_app/data/services/users_client.dart';
import 'package:itk_app/domain/models/wiki_file.dart';
import 'package:itk_app/utils/result.dart';

class WikiFilesRepository {
  WikiFilesRepository({
    required UsersClient usersClient,
  }) : _usersClient = usersClient;

  final UsersClient _usersClient;

  Future<Result<List<WikiFile>>> listDir(String dir, String user) async => await _usersClient.getJson('/~$user/files_wiki.php', parse: parseFiles, queryParameters: {'dir': dir});

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
