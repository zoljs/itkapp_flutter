import 'package:flutter_test/flutter_test.dart';
import 'package:itk_app/domain/models/wiki_file.dart';
import 'package:itk_app/ui/wiki/viewmodels/wiki_files_viewmodel.dart';
import 'package:itk_app/utils/result.dart';

import '../../helpers/fake_http.dart';
import '../../helpers/fake_repositories.dart';

void main() {
  late FakeWikiFilesRepository repository;

  setUp(() => repository = FakeWikiFilesRepository());

  Future<WikiFilesViewModel> create({String dir = '', String user = 'perpa4'}) async {
    final viewModel = WikiFilesViewModel(repository: repository, dir: dir, user: user);
    await flush();
    return viewModel;
  }

  test('a saját mappáját tölti be', () async {
    repository.listResult = Ok([WikiFile(name: 'zh1.pdf', isDir: false)]);

    final viewModel = await create(dir: 'Analizis', user: 'naszy');

    expect(repository.calls.single, ('Analizis', 'naszy'));
    expect(viewModel.items.single.name, 'zh1.pdf');
    viewModel.dispose();
  });

  group('cím', () {
    test('a gyökérben "Fájlok"', () async {
      final viewModel = await create();
      expect(viewModel.title, 'Fájlok');
      viewModel.dispose();
    });

    test('almappában az utolsó mappa neve', () async {
      final viewModel = await create(dir: 'Analizis/2025');
      expect(viewModel.title, '2025');
      viewModel.dispose();
    });
  });

  group('útvonalak', () {
    test('a gyökérben a fájl neve', () async {
      final viewModel = await create();
      expect(viewModel.childPath('zh1.pdf'), 'zh1.pdf');
      viewModel.dispose();
    });

    test('almappában a mappa + név', () async {
      final viewModel = await create(dir: 'Analizis');
      expect(viewModel.childPath('zh1.pdf'), 'Analizis/zh1.pdf');
      viewModel.dispose();
    });

    test('a site URL a userből jön', () async {
      final viewModel = await create(user: 'naszy');
      expect(viewModel.siteUrl, 'https://users.itk.ppke.hu/~naszy');
      viewModel.dispose();
    });

    test('a fájl URL kódolja a szóközt és az ékezetet', () async {
      final viewModel = await create(dir: 'Analízis 1');
      expect(
        viewModel.fileUrl('zh 1.pdf'),
        'https://users.itk.ppke.hu/~perpa4/files/Anal%C3%ADzis%201/zh%201.pdf',
      );
      viewModel.dispose();
    });
  });
}
