import 'package:flutter/foundation.dart';
import 'package:itk_app/data/repositories/auth_repository.dart';
import 'package:itk_app/data/repositories/files_repository.dart';
import 'package:itk_app/domain/models/wiki_file.dart';
import 'package:itk_app/utils/command.dart';
import 'package:itk_app/utils/result.dart';

class FilesSetupViewModel extends ChangeNotifier {
  final FilesRepository _filesRepository;
  final AuthRepository _authRepository;

  static const installCommand = 'mkdir -p ~/public_html/files && '
      'curl -fsSL https://test.app.itk.ppke.hu/dl/files_wiki.php -o ~/public_html/files_wiki.php && '
      'chmod 644 ~/public_html/files_wiki.php';

  FilesSetupViewModel({
    required FilesRepository filesRepository,
    required AuthRepository authRepository,
  })  : _authRepository = authRepository,
        _filesRepository = filesRepository {
    check = Command0<List<WikiFile>>(_check);
  }

  // State
  late final Command0<List<WikiFile>> check;

  // Getters
  String? get _login => _authRepository.cachedUser?.login;
  String get sshCommand => 'ssh ${_login ?? '<shibboleth>'}@users.itk.ppke.hu';

  // Methods
  Future<Result<List<WikiFile>>> _check() async {
    final login = _login;
    if (login == null) return const Err('Jelentkezz be újra.');
    return _filesRepository.listDir('', login);
  }

  @override
  void dispose() {
    check.dispose();
    super.dispose();
  }
}
