import 'package:flutter_test/flutter_test.dart';
import 'package:itk_app/ui/core/screens/viewmodels/picker_viewmodel.dart';
import 'package:itk_app/utils/result.dart';

import '../../helpers/fake_http.dart';

void main() {
  late Result<List<String>> fetched;
  late List<String> askedWith;

  PickerViewModel<String> create() => PickerViewModel<String>(
        fetch: () async => fetched,
        matches: (item, query) {
          askedWith.add(query);
          return item.toLowerCase().contains(query);
        },
      );

  setUp(() {
    fetched = const Ok(['Analízis', 'Programozás', 'Algebra']);
    askedWith = [];
  });

  test('betöltés után megvannak az elemek, szűrés nélkül mind látszik',
      () async {
    final viewModel = create();
    await flush();

    expect(viewModel.items, ['Analízis', 'Programozás', 'Algebra']);
    expect(viewModel.filteredItems, hasLength(3));
    expect(viewModel.load.errorMessage, isNull);
    viewModel.dispose();
  });

  test('a szűrés a matches szabályt használja', () async {
    final viewModel = create();
    await flush();

    viewModel.setQuery('prog');

    expect(viewModel.filteredItems, ['Programozás']);
    viewModel.dispose();
  });

  test('a matches levágott, kisbetűs keresőszöveget kap', () async {
    final viewModel = create();
    await flush();

    viewModel.setQuery('  PROG ');
    viewModel.filteredItems;

    expect(askedWith.toSet(), {'prog'});
    viewModel.dispose();
  });

  test('üres vagy csak szóközből álló keresésnél nem hívja a matches-t',
      () async {
    final viewModel = create();
    await flush();

    viewModel.setQuery('   ');

    expect(viewModel.filteredItems, hasLength(3));
    expect(askedWith, isEmpty);
    viewModel.dispose();
  });

  test('az items nem módosítható kívülről', () async {
    final viewModel = create();
    await flush();

    expect(() => viewModel.items.add('x'), throwsUnsupportedError);
    viewModel.dispose();
  });

  test('a setQuery értesít', () async {
    final viewModel = create();
    await flush();
    var notified = 0;
    viewModel.addListener(() => notified++);

    viewModel.setQuery('a');

    expect(notified, 1);
    viewModel.dispose();
  });

  group('hiba', () {
    setUp(() => fetched = const Err('Hiba történt.'));

    test('az elemek üresek maradnak, a load hibaüzenetet kap', () async {
      final viewModel = create();
      await flush();

      expect(viewModel.items, isEmpty);
      expect(viewModel.load.errorMessage, 'Hiba történt.');
      viewModel.dispose();
    });

    test('a VM értesít, amikor a hibaüzenet már látszik (nem ragad a skeleton)',
        () async {
      final viewModel = create();
      final errorsSeen = <String?>[];
      viewModel.addListener(() => errorsSeen.add(viewModel.load.errorMessage));
      await flush();

      expect(errorsSeen, isNotEmpty);
      expect(errorsSeen.last, 'Hiba történt.');
      viewModel.dispose();
    });
  });
}
