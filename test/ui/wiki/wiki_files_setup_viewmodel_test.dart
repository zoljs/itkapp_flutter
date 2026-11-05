import 'package:flutter_test/flutter_test.dart';
import 'package:itk_app/domain/models/wiki_file.dart';
import 'package:itk_app/ui/wiki/viewmodels/wiki_files_setup_viewmodel.dart';
import 'package:itk_app/utils/result.dart';

import '../../helpers/fake_repositories.dart';
import '../../helpers/fixtures.dart';

void main() {
  late FakeWikiFilesRepository files;
  late FakeAuthRepository auth;
  late WikiFilesSetupViewModel viewModel;

  setUp(() {
    files = FakeWikiFilesRepository();
    auth = FakeAuthRepository()..cachedUser = user();
    viewModel = WikiFilesSetupViewModel(
        wikiFilesRepository: files, authRepository: auth);
  });

  tearDown(() => viewModel.dispose());

  test('az ssh parancs a saját loginnal készül', () {
    expect(viewModel.sshCommand, 'ssh perpa4@users.itk.ppke.hu');
  });

  test('a telepítő parancs a backendről tölt, a public_html-be ír', () {
    expect(WikiFilesSetupViewModel.installCommand,
        contains('https://test.app.itk.ppke.hu/dl/files_wiki.php'));
    expect(WikiFilesSetupViewModel.installCommand,
        contains('-o ~/public_html/files_wiki.php'));
  });

  test('ellenőrzéskor a saját gyökérmappát kéri', () async {
    files.listResult = Ok([WikiFile(name: 'zh1.pdf', isDir: false)]);

    await viewModel.check.execute();

    expect(files.calls.single, ('', 'perpa4'));
    expect(viewModel.check.completed, isTrue);
  });

  test('hiba esetén a hibaüzenet elérhető a képernyőnek', () async {
    files.listResult = const Err('Hiányzik a files mappa.');

    await viewModel.check.execute();

    expect(viewModel.check.completed, isFalse);
    expect(viewModel.check.errorMessage, 'Hiányzik a files mappa.');
  });

  test('bejelentkezés nélkül nem kér semmit, Err', () async {
    auth.cachedUser = null;

    await viewModel.check.execute();

    expect(files.calls, isEmpty);
    expect(viewModel.check.completed, isFalse);
  });
}
