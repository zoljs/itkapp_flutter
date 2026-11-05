import 'package:flutter_test/flutter_test.dart';
import 'package:itk_app/domain/models/calendar_event.dart';
import 'package:itk_app/domain/models/event.dart';
import 'package:itk_app/ui/events/viewmodels/events_viewmodel.dart';
import 'package:itk_app/utils/result.dart';
import 'package:itk_app/utils/semester.dart';

import '../../helpers/fake_http.dart';
import '../../helpers/fake_repositories.dart';
import '../../helpers/fixtures.dart';

void main() {
  late FakeEventRepository events;
  late FakeAuthRepository auth;
  late FakeCalendarRepository calendar;

  setUp(() {
    events = FakeEventRepository();
    auth = FakeAuthRepository();
    calendar = FakeCalendarRepository();
  });

  EventsViewModel create(Set<EventType> types) => EventsViewModel(
        eventRepository: events,
        calendarRepository: calendar,
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

  group('tárgyaim szűrő (naptár alapján)', () {
    // Relative to today, so the tests don't break when the semester changes.
    CalendarEvent lesson(String? subject, {DateTime? start}) {
      final s = start ?? DateTime.now();
      return CalendarEvent(title: 'Óra', start: s, end: s.add(const Duration(hours: 2)), subject: subject);
    }

    setUp(() {
      events.getResult = Ok([
        event(id: 1, subject: analysis, location: '318'),
        event(id: 2, subject: programming, location: 'Aula'),
      ]);
    });

    test('alapból az összeset mutatja (HIG: tágabb scope az alap)', () async {
      calendar.getResult = Ok([lesson('Analízis I.')]);
      final viewModel = create({EventType.midterm});
      await flush();

      expect(viewModel.onlyMySubjects, isFalse);
      expect(viewModel.filteredEvents.map((e) => e.id), [1, 2]);
      viewModel.dispose();
    });

    test('bekapcsolva csak a naptárban szereplő tárgyak zh-it mutatja', () async {
      calendar.getResult = Ok([lesson('Analízis I.'), lesson(null)]);
      final viewModel = create({EventType.midterm});
      await flush();
      viewModel.setOnlyMySubjects(true);

      expect(viewModel.hasMySubjects, isTrue);
      expect(viewModel.mySubjects, {'Analízis I.'});
      expect(viewModel.filteredEvents.map((e) => e.id), [1]);
      viewModel.dispose();
    });

    test('az előző félév tárgyai nem számítanak', () async {
      final lastSemester = currentSemesterStart().subtract(const Duration(days: 1));
      calendar.getResult = Ok([
        lesson('Analízis I.'),
        lesson('Programozás alapjai', start: lastSemester),
      ]);
      final viewModel = create({EventType.midterm});
      await flush();
      viewModel.setOnlyMySubjects(true);

      expect(viewModel.mySubjects, {'Analízis I.'});
      expect(viewModel.filteredEvents.map((e) => e.id), [1]);
      viewModel.dispose();
    });

    test('vissza is kapcsolható az összesre', () async {
      calendar.getResult = Ok([lesson('Analízis I.')]);
      final viewModel = create({EventType.midterm});
      await flush();

      viewModel.setOnlyMySubjects(true);
      viewModel.setOnlyMySubjects(false);

      expect(viewModel.filteredEvents.map((e) => e.id), [1, 2]);
      viewModel.dispose();
    });

    test('üres naptárral nem szűr', () async {
      calendar.getResult = const Ok([]);
      final viewModel = create({EventType.midterm});
      await flush();
      viewModel.setOnlyMySubjects(true);

      expect(viewModel.hasMySubjects, isFalse);
      expect(viewModel.filteredEvents.map((e) => e.id), [1, 2]);
      viewModel.dispose();
    });

    test('naptár hiba esetén a zh-k betöltődnek, szűrés nélkül', () async {
      calendar.getResult = const Err('Nem sikerült betölteni a naptárat.');
      final viewModel = create({EventType.midterm});
      await flush();
      viewModel.setOnlyMySubjects(true);

      expect(viewModel.load.completed, isTrue);
      expect(viewModel.load.errorMessage, isNull);
      expect(viewModel.hasMySubjects, isFalse);
      expect(viewModel.filteredEvents.map((e) => e.id), [1, 2]);
      viewModel.dispose();
    });

    test('isSubjectFilterActive: csak bekapcsolva ÉS van naptár', () async {
      calendar.getResult = Ok([lesson('Analízis I.')]);
      final withCalendar = create({EventType.midterm});
      await flush();
      expect(withCalendar.isSubjectFilterActive, isFalse);
      withCalendar.setOnlyMySubjects(true);
      expect(withCalendar.isSubjectFilterActive, isTrue);
      withCalendar.dispose();

      calendar.getResult = const Ok([]);
      final withoutCalendar = create({EventType.midterm});
      await flush();
      withoutCalendar.setOnlyMySubjects(true);
      expect(withoutCalendar.isSubjectFilterActive, isFalse);
      withoutCalendar.dispose();
    });

    test('a keresés és a tárgy szűrő együtt érvényes', () async {
      calendar.getResult = Ok([lesson('Analízis I.')]);
      final viewModel = create({EventType.midterm});
      await flush();
      viewModel.setOnlyMySubjects(true);

      viewModel.setQuery('aula');
      expect(viewModel.filteredEvents, isEmpty);

      viewModel.setOnlyMySubjects(false);
      expect(viewModel.filteredEvents.map((e) => e.id), [2]);
      viewModel.dispose();
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

  group('típus szűrő', () {
    late EventsViewModel viewModel;

    setUp(() async {
      events.getResult = Ok([
        event(id: 1, subject: analysis, type: EventType.midterm),
        event(id: 2, subject: programming, type: EventType.retake),
        event(id: 3, subject: analysis, type: EventType.retake),
      ]);
      viewModel = create({EventType.midterm, EventType.retake});
      await flush();
    });

    tearDown(() => viewModel.dispose());

    test('alapból nincs kiválasztott típus, minden látszik', () {
      expect(viewModel.selectedTypes, isEmpty);
      expect(viewModel.filteredEvents.map((e) => e.id), [1, 2, 3]);
    });

    test('egy típust kiválasztva csak az látszik', () {
      viewModel.setTypeSelected(EventType.retake, true);

      expect(viewModel.selectedTypes, {EventType.retake});
      expect(viewModel.filteredEvents.map((e) => e.id), [2, 3]);
    });

    test('több kiválasztott típus közül bármelyik megfelel', () {
      viewModel.setTypeSelected(EventType.midterm, true);
      viewModel.setTypeSelected(EventType.retake, true);

      expect(viewModel.filteredEvents.map((e) => e.id), [1, 2, 3]);
    });

    test('kikapcsolva újra minden látszik', () {
      viewModel.setTypeSelected(EventType.retake, true);
      viewModel.setTypeSelected(EventType.retake, false);

      expect(viewModel.selectedTypes, isEmpty);
      expect(viewModel.filteredEvents, hasLength(3));
    });

    test('ugyanazt kétszer bekapcsolva sem duplázódik', () {
      viewModel.setTypeSelected(EventType.retake, true);
      viewModel.setTypeSelected(EventType.retake, true);

      expect(viewModel.selectedTypes, {EventType.retake});
      viewModel.setTypeSelected(EventType.retake, false);
      expect(viewModel.selectedTypes, isEmpty);
    });

    test('a keresés és a típus együtt szűr (ÉS)', () {
      viewModel.setTypeSelected(EventType.retake, true);
      viewModel.setQuery('analízis');

      expect(viewModel.filteredEvents.map((e) => e.id), [3]);
    });

    test('változáskor értesít', () {
      var notified = 0;
      viewModel.addListener(() => notified++);

      viewModel.setTypeSelected(EventType.retake, true);

      expect(notified, 1);
    });

    test('a kiválasztás nem módosítható kívülről', () {
      expect(
        () => viewModel.selectedTypes.add(EventType.midterm),
        throwsUnsupportedError,
      );
    });
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
