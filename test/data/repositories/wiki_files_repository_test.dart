import 'package:flutter_test/flutter_test.dart';
import 'package:itk_app/data/repositories/wiki_files_repository.dart';
import 'package:itk_app/data/services/users_client.dart';
import 'package:itk_app/domain/models/wiki_file.dart';
import 'package:itk_app/utils/result.dart';

import '../../helpers/fake_http.dart';

void main() {
  late FakeHttpAdapter adapter;
  late WikiFilesRepository repository;

  setUp(() {
    adapter = FakeHttpAdapter();
    final client = UsersClient()..dio.httpClientAdapter = adapter;
    repository = WikiFilesRepository(usersClient: client);
  });

  test("a user mappájából kér, a 'dir' query paraméterben", () async {
    adapter.handler = (_) => jsonBody(200, [
          {'name': 'zh1.pdf', 'type': 'file'},
        ]);

    final result = await repository.listDir('Analizis/2025', 'perpa4');

    expect(adapter.last.path, '/~perpa4/files_wiki.php');
    expect(adapter.last.queryParameters['dir'], 'Analizis/2025');
    expect(result, isA<Ok<List<WikiFile>>>().having((r) => r.value.single.name, 'name', 'zh1.pdf'));
  });

  test('túl sok fájl Err, nem fagy le', () async {
    adapter.handler = (_) => jsonBody(
          200,
          List.generate(WikiFile.maxFiles + 1, (i) => {'name': 'f$i', 'type': 'file'}),
        );

    final result = await repository.listDir('', 'perpa4');

    expect(result, isA<Err<List<WikiFile>>>());
  });

  test('nem JSON lista (pl. HTML hibaoldal) Err', () async {
    adapter.handler = (_) => textBody(200, '<html>Not Found</html>');

    expect(await repository.listDir('', 'perpa4'), isA<Err<List<WikiFile>>>());
  });
}
