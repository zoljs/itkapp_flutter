import 'package:flutter_test/flutter_test.dart';
import 'package:itk_app/domain/models/event.dart';
import 'package:itk_app/ui/events/viewmodels/events_viewmodel.dart';
import 'package:itk_app/utils/result.dart';

import '../../helpers/fake_http.dart';
import '../../helpers/fake_repositories.dart';
import '../../helpers/fixtures.dart';

void main() {
  late FakeEventRepository events;
  late FakeAuthRepository auth;

  setUp(() {
    events = FakeEventRepository();
    auth = FakeAuthRepository();
  });

  EventsViewModel create(Set<EventType> types) => EventsViewModel(
        eventRepository: events,
        authRepository: auth,
        types: types,
      );

  test('a saját típusait tölti be, cache-ből', () async {
    final viewModel = create({EventType.consultation});
    await flush();

    expect(events.getCalls.single.types, {EventType.consultation});
    expect(events.getCalls.single.forceReload, isFalse);
    viewModel.dispose();
  });

  test('betöltés után megvannak az események', () async {
    events.getResult = Ok([event(id: 1), event(id: 2)]);

    final viewModel = create({EventType.midterm, EventType.retake});
    await flush();

    expect(viewModel.events.map((e) => e.id), [1, 2]);
    expect(viewModel.initialLoading, isFalse);
    viewModel.dispose();
  });

  group('keresés', () {
    late EventsViewModel viewModel;

    setUp(() async {
      events.getResult = Ok([
        event(id: 1, subject: analysis, location: '318'),
        event(id: 2, subject: programming, location: 'Aula'),
      ]);
      viewModel = create({EventType.midterm});
      await flush();
    });

    tearDown(() => viewModel.dispose());

    test('név szerint, kis-nagybetű függetlenül', () {
      viewModel.setQuery('ANALÍZIS');
      expect(viewModel.filteredEvents.map((e) => e.id), [1]);
    });

    test('tárgykód szerint', () {
      viewModel.setQuery('itk202');
      expect(viewModel.filteredEvents.map((e) => e.id), [2]);
    });

    test('helyszín szerint', () {
      viewModel.setQuery('aula');
      expect(viewModel.filteredEvents.map((e) => e.id), [2]);
    });

    test('üres keresés mindent mutat', () {
      viewModel.setQuery('   ');
      expect(viewModel.filteredEvents, hasLength(2));
    });
  });

  test('canModerate az évfolyamfelelős jogból jön', () async {
    final viewModel = create({EventType.midterm});
    await flush();
    expect(viewModel.canModerate, isFalse);

    auth.cachedUser = user(canModerateMidterms: true);
    expect(viewModel.canModerate, isTrue);
    viewModel.dispose();
  });

  group('törlés', () {
    test('azonnal kiveszi a listából', () async {
      events.getResult = Ok([event(id: 1), event(id: 2)]);
      final viewModel = create({EventType.midterm});
      await flush();

      await viewModel.delete.execute(1);

      expect(events.deletedIds, [1]);
      expect(viewModel.events.map((e) => e.id), [2]);
      viewModel.dispose();
    });

    test('hiba esetén a szerverről újratölt, a sor visszakerül', () async {
      events.getResult = Ok([event(id: 1), event(id: 2)]);
      final viewModel = create({EventType.midterm});
      await flush();

      events.deleteResult = const Err('Nincs jogosultság.');
      await viewModel.delete.execute(1);

      expect(viewModel.delete.errorMessage, 'Nincs jogosultság.');
      expect(events.getCalls.last.forceReload, isTrue);
      expect(viewModel.events.map((e) => e.id), [1, 2]);
      viewModel.dispose();
    });
  });
}
