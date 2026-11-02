import 'package:flutter/foundation.dart';
import 'package:itk_app/data/repositories/files_repository.dart';
import 'package:itk_app/domain/models/wiki_file.dart';
import 'package:itk_app/utils/command.dart';
import 'package:itk_app/utils/result.dart';

class FilesSetupViewmodel extends ChangeNotifier {
  final FilesRepository _repository;
  final String _login;

  static const installCommand = 'mkdir -p ~/public_html/files && '
      'curl -fsSL https://test.app.itk.ppke.hu/dl/files_wiki.php -o ~/public_html/files_wiki.php && '
      'chmod 644 ~/public_html/files_wiki.php';

  FilesSetupViewmodel({
    required FilesRepository repository,
    required String login,
  })  : _login = login,
        _repository = repository {
    check = Command0<List<WikiFile>>(_check);
  }

  // State
  late final Command0<List<WikiFile>> check;

  // Getters
  String get sshCommand => 'ssh $_login@users.itk.ppke.hu';

  // Methods
  Future<Result<List<WikiFile>>> _check() => _repository.listDir('', _login);

  @override
  void dispose() {
    check.dispose();
    super.dispose();
  }
}
