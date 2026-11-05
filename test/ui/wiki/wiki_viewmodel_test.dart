import 'dart:async';

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
    viewModel = WikiViewModel(
        wikiSitesRepository: FakeSitesRepository(), wikiFilesRepository: files);
    await flush();
  });

  tearDown(() => viewModel.dispose());

  group('checkFiles', () {
    test('működő PHP esetén completed, a gyökérmappát kéri', () async {
      files.listResult = Ok([WikiFile(name: 'zh1.pdf', isDir: false)]);

      await viewModel.checkFiles.execute('perpa4');

      expect(viewModel.checkFiles.completed, isTrue);
      expect(files.calls.single, ('', 'perpa4'));
    });

    test('futás közben a user az ellenőrzött, utána null', () async {
      files.gate = Completer<void>();

      final run = viewModel.checkFiles.execute('perpa4');
      await flush();

      expect(viewModel.checkFiles.running, isTrue);
      expect(viewModel.checkingLogin, 'perpa4');

      files.gate!.complete();
      await run;

      expect(viewModel.checkingLogin, isNull);
    });

    test('hiba után is null', () async {
      files.listResult = const Err('Hiba.');

      await viewModel.checkFiles.execute('perpa4');

      expect(viewModel.checkingLogin, isNull);
    });

    test('hiba esetén (nincs PHP, régi PHP, timeout) nem completed', () async {
      files.listResult = const Err('Hiba.');

      await viewModel.checkFiles.execute('perpa4');

      expect(viewModel.checkFiles.completed, isFalse);
    });
  });
}
