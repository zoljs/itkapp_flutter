import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:itk_app/domain/models/wiki_file.dart';
import 'package:itk_app/ui/wiki/viewmodels/wiki_files_viewmodel.dart';
import 'package:itk_app/utils/result.dart';

import '../../helpers/fake_http.dart';
import '../../helpers/fake_repositories.dart';

void main() {
  late FakeWikiFilesRepository repository;

  setUp(() => repository = FakeWikiFilesRepository());

  Future<WikiFilesViewModel> create(
      {String dir = '', String user = 'perpa4'}) async {
    final viewModel =
        WikiFilesViewModel(repository: repository, dir: dir, user: user);
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

    test('a fájl URL kódolja a # és ? karaktert', () async {
      final viewModel = await create();
      expect(
        viewModel.fileUrl('zh1#2?.pdf'),
        'https://users.itk.ppke.hu/~perpa4/files/zh1%232%3F.pdf',
      );
      viewModel.dispose();
    });

    test('a fájl URL kihagyja az üres mappa-darabokat', () async {
      final viewModel = await create(dir: '/Analizis//ZH/');
      expect(
        viewModel.fileUrl('x.pdf'),
        'https://users.itk.ppke.hu/~perpa4/files/Analizis/ZH/x.pdf',
      );
      viewModel.dispose();
    });
  });

  group('első betöltés', () {
    test('betöltés közben igaz, utána hamis', () async {
      repository.gate = Completer<void>();
      final viewModel =
          WikiFilesViewModel(repository: repository, dir: '', user: 'perpa4');
      await flush();
      expect(viewModel.initialLoading, isTrue);

      repository.gate!.complete();
      await flush();
      expect(viewModel.initialLoading, isFalse);
      viewModel.dispose();
    });

    test('frissítéskor hamis, ha már vannak elemek', () async {
      repository.listResult = Ok([WikiFile(name: 'zh1.pdf', isDir: false)]);
      final viewModel = await create();

      repository.gate = Completer<void>();
      unawaited(viewModel.load.execute());
      await flush();
      expect(viewModel.load.running, isTrue);
      expect(viewModel.initialLoading, isFalse);

      repository.gate!.complete();
      await flush();
      viewModel.dispose();
    });
  });
}
