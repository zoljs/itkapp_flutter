import 'package:itk_app/data/services/users_client.dart';
import 'package:itk_app/domain/models/wiki_file.dart';
import 'package:itk_app/utils/result.dart';

class WikiFilesRepository {
  WikiFilesRepository({
    required UsersClient usersClient,
  }) : _usersClient = usersClient;

  final UsersClient _usersClient;

  Future<Result<List<WikiFile>>> listDir(String dir, String user) async => _usersClient.getJson('/~$user/files_wiki.php', parse: WikiFile.parseList, queryParameters: {'dir': dir});
}
