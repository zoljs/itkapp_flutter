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
    viewModel = WikiViewModel(sitesRepository: FakeSitesRepository(), wikiFilesRepository: files);
    await flush();
  });

  tearDown(() => viewModel.dispose());

  group('hasFileList', () {
    test('működő PHP esetén true, a gyökérmappát kéri', () async {
      files.listResult = Ok([WikiFile(name: 'zh1.pdf', isDir: false)]);

      expect(await viewModel.hasFileList('perpa4'), isTrue);
      expect(files.calls.single, ('', 'perpa4'));
    });

    test('hiba esetén (nincs PHP, régi PHP, timeout) false', () async {
      files.listResult = const Err('Hiba.');

      expect(await viewModel.hasFileList('perpa4'), isFalse);
    });
  });
}
