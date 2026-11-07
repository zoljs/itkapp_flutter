import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:itk_app/data/repositories/wiki_files_repository.dart';
import 'package:itk_app/domain/models/wiki_file.dart';
import 'package:itk_app/ui/wiki/wiki_files_screen.dart';
import 'package:itk_app/utils/result.dart';
import 'package:provider/provider.dart';

import '../../helpers/fake_repositories.dart';

/// A new [WikiFilesScreen] instance on every call, like go_router's
/// `pageBuilder` on every navigation.
Widget _app(WikiFilesRepository repository, {required String dir}) =>
    Provider<WikiFilesRepository>.value(
      value: repository,
      child: MaterialApp(
        home: WikiFilesScreen(dir: dir, user: 'naszy'),
      ),
    );

void main() {
  testWidgets('újraépítéskor nem tölt újra', (tester) async {
    final repository = FakeWikiFilesRepository()
      ..listResult = Ok([WikiFile(name: 'zh1.pdf', isDir: false)]);

    await tester.pumpWidget(_app(repository, dir: 'Analizis'));
    await tester.pumpAndSettle();
    await tester.pumpWidget(_app(repository, dir: 'Analizis'));
    await tester.pumpAndSettle();

    expect(repository.calls.length, 1);
    expect(find.text('zh1.pdf'), findsOneWidget);
  });
}
