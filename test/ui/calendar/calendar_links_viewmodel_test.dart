import 'package:flutter_test/flutter_test.dart';
import 'package:itk_app/domain/models/calendar_link.dart';
import 'package:itk_app/ui/calendar/viewmodels/calendar_links_viewmodel.dart';
import 'package:itk_app/utils/result.dart';

import '../../helpers/fake_http.dart';
import '../../helpers/fake_repositories.dart';
import '../../helpers/fixtures.dart';

void main() {
  late FakeCalendarLinksRepository links;
  late FakeCalendarRepository calendar;

  setUp(() {
    links = FakeCalendarLinksRepository();
    calendar = FakeCalendarRepository();
  });

  Future<CalendarLinksViewmodel> create() async {
    final viewModel = CalendarLinksViewmodel(repository: links, calendarRepository: calendar);
    await flush();
    return viewModel;
  }

  test('betöltéskor lekéri a linkeket', () async {
    links.getResult = Ok([link(id: 1), link(id: 2, name: 'Moodle')]);

    final viewModel = await create();

    expect(viewModel.links.map((l) => l.name), ['Neptun', 'Moodle']);
    viewModel.dispose();
  });

  group('canAdd', () {
    test('név és URL kell hozzá', () async {
      final viewModel = await create();
      expect(viewModel.canAdd, isFalse);

      viewModel.setName('Neptun');
      expect(viewModel.canAdd, isFalse);

      viewModel.setUrl('https://n/c.ics');
      expect(viewModel.canAdd, isTrue);
      viewModel.dispose();
    });

    test('csak szóközökből álló név nem elég', () async {
      final viewModel = await create()
        ..setName('   ')
        ..setUrl('https://n/c.ics');

      expect(viewModel.canAdd, isFalse);
      viewModel.dispose();
    });

    test('10 linknél tele van', () async {
      links.getResult = Ok([for (var i = 0; i < 10; i++) link(id: i)]);
      final viewModel = await create()
        ..setName('Új')
        ..setUrl('https://x/c.ics');

      expect(viewModel.isFull, isTrue);
      expect(viewModel.canAdd, isFalse);
      viewModel.dispose();
    });
  });

  test('hozzáadás: trimmel, üríti a mezőket és a naptár cache-t, újratölt', () async {
    final viewModel = await create()
      ..setName('  Edzés ')
      ..setUrl(' https://x/c.ics ')
      ..setSyncInterval(SyncInterval.hourly);
    final loadsBefore = links.getCount;

    await viewModel.add.execute();

    expect(links.lastAdd?.name, 'Edzés');
    expect(links.lastAdd?.url, 'https://x/c.ics');
    expect(links.lastAdd?.syncInterval, SyncInterval.hourly);
    expect(viewModel.canAdd, isFalse, reason: 'a mezőknek ki kell ürülniük');
    expect(calendar.clearCount, 1);
    expect(links.getCount, loadsBefore + 1);
    viewModel.dispose();
  });

  test('sikertelen hozzáadásnál a mezők maradnak', () async {
    links.addResult = const Err('Ez a link már fel van véve.');
    final viewModel = await create()
      ..setName('Neptun')
      ..setUrl('https://n/c.ics');

    await viewModel.add.execute();

    expect(viewModel.add.errorMessage, 'Ez a link már fel van véve.');
    expect(viewModel.canAdd, isTrue);
    expect(calendar.clearCount, 0);
    viewModel.dispose();
  });

  group('törlés', () {
    test('azonnal kiveszi, és üríti a naptár cache-t', () async {
      links.getResult = Ok([link(id: 1), link(id: 2)]);
      final viewModel = await create();

      links.getResult = Ok([link(id: 2)]);
      await viewModel.delete.execute(1);

      expect(links.deletedIds, [1]);
      expect(viewModel.links.map((l) => l.id), [2]);
      expect(calendar.clearCount, 1);
      viewModel.dispose();
    });

    test('hiba esetén a link visszakerül', () async {
      links.getResult = Ok([link(id: 1), link(id: 2)]);
      final viewModel = await create();

      links.deleteResult = const Err('Ez a link már nem létezik.');
      await viewModel.delete.execute(1);

      expect(viewModel.delete.errorMessage, 'Ez a link már nem létezik.');
      expect(viewModel.links.map((l) => l.id), [1, 2]);
      viewModel.dispose();
    });
  });
}
