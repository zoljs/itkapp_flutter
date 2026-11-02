import 'package:flutter_test/flutter_test.dart';
import 'package:itk_app/domain/models/wiki_file.dart';
import 'package:itk_app/ui/wiki/viewmodels/wiki_viewmodel.dart';
import 'package:itk_app/utils/result.dart';

import '../../helpers/fake_http.dart';
import '../../helpers/fake_repositories.dart';

void main() {
  late FakeWikiFilesRepository files;
  late WikiViewModel viewModel;

  setUp(() async {
    files = FakeWikiFilesRepository();
    viewModel = WikiViewModel(wikiSitesRepository: FakeSitesRepository(), wikiFilesRepository: files);
    await flush();
  });

  tearDown(() => viewModel.dispose());

  group('checkFiles', () {
    test('működő PHP esetén completed, a gyökérmappát kéri, megjegyzi a usert', () async {
      files.listResult = Ok([WikiFile(name: 'zh1.pdf', isDir: false)]);

      await viewModel.checkFiles.execute('perpa4');

      expect(viewModel.checkFiles.completed, isTrue);
      expect(files.calls.single, ('', 'perpa4'));
      expect(viewModel.checkingLogin, 'perpa4');
    });

    test('hiba esetén (nincs PHP, régi PHP, timeout) nem completed', () async {
      files.listResult = const Err('Hiba.');

      await viewModel.checkFiles.execute('perpa4');

      expect(viewModel.checkFiles.completed, isFalse);
    });
  });
}
