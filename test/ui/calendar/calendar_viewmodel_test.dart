import 'package:flutter_test/flutter_test.dart';
import 'package:itk_app/domain/models/calendar_event.dart';
import 'package:itk_app/ui/calendar/viewmodels/calendar_viewmodel.dart';
import 'package:itk_app/utils/result.dart';

import '../../helpers/fake_http.dart';
import '../../helpers/fake_repositories.dart';

CalendarEvent _event(
  String title,
  DateTime start,
  DateTime end, {
  String? location,
}) =>
    CalendarEvent(title: title, start: start, end: end, location: location);

void main() {
  group('displayEnd', () {
    final start = DateTime(2026, 11, 5, 10);

    test('normál esemény vége nem változik', () {
      final end = DateTime(2026, 11, 5, 11, 30);
      expect(CalendarViewModel.displayEnd(start, end), end);
    });

    test('pillanatnyi esemény 15 perces blokkot kap', () {
      expect(CalendarViewModel.displayEnd(start, start),
          DateTime(2026, 11, 5, 10, 15));
    });

    test('a kezdés előtti vég is 15 perces blokkot kap', () {
      expect(CalendarViewModel.displayEnd(start, DateTime(2026, 11, 5, 9)),
          DateTime(2026, 11, 5, 10, 15));
    });

    test('éjfélre végződő esemény 23:59-kor ér véget ugyanazon a napon', () {
      final dayStart = DateTime(2026, 11, 5);
      final nextMidnight = DateTime(2026, 11, 6);
      expect(CalendarViewModel.displayEnd(dayStart, nextMidnight),
          DateTime(2026, 11, 5, 23, 59));
    });

    test('éjfél előtti pillanatnyi esemény nem lóg át a következő napra', () {
      final lateStart = DateTime(2026, 11, 5, 23, 50);
      final result = CalendarViewModel.displayEnd(lateStart, lateStart);
      expect(result.day, 5);
      expect(result.isAfter(lateStart), isTrue);
    });
  });

  group('toPlannerEvents', () {
    test('cím, helyszín és az eredeti esemény átkerül', () {
      final source = _event(
          'Analízis', DateTime(2026, 11, 5, 10), DateTime(2026, 11, 5, 12),
          location: '318');

      final result = CalendarViewModel.toPlannerEvents([source]).single;

      expect(result.title, 'Analízis');
      expect(result.description, '318');
      expect(result.data, same(source));
      expect(result.startTime, DateTime(2026, 11, 5, 10));
      expect(result.endTime, DateTime(2026, 11, 5, 12));
    });
  });

  group('egész napos események', () {
    test('a planner egész napos eseményként kapja meg', () {
      final holiday =
          _event('Szünnap', DateTime(2026, 11, 5), DateTime(2026, 11, 5));
      final lesson = _event(
          'Analízis', DateTime(2026, 11, 5, 10), DateTime(2026, 11, 5, 12));

      final result = CalendarViewModel.toPlannerEvents([holiday, lesson]);

      expect(result.map((e) => e.isFullDay), [true, false]);
    });

    test('egynapos egész napos esemény csak a saját napján jelenik meg',
        () async {
      final calendar = FakeCalendarRepository()
        ..getResult = Ok([
          _event('Szünnap', DateTime(2026, 11, 5), DateTime(2026, 11, 6)),
        ]);
      final viewModel = CalendarViewModel(repository: calendar);
      await flush();

      final controller = viewModel.eventController;
      expect(controller.getFilteredDayEvents(DateTime(2026, 11, 5))?.length, 1);
      expect(controller.getFilteredDayEvents(DateTime(2026, 11, 6)) ?? [],
          isEmpty);
      viewModel.dispose();
    });

    test('hasAllDayEvents csak akkor igaz, ha van egész napos', () async {
      final calendar = FakeCalendarRepository()
        ..getResult = Ok([
          _event(
              'Analízis', DateTime(2026, 11, 5, 10), DateTime(2026, 11, 5, 12)),
        ]);
      final viewModel = CalendarViewModel(repository: calendar);
      await flush();
      expect(viewModel.hasAllDayEvents, isFalse);

      calendar.getResult = Ok([
        _event('Szünnap', DateTime(2026, 11, 5), DateTime(2026, 11, 5)),
      ]);
      await viewModel.load.execute(true);
      expect(viewModel.hasAllDayEvents, isTrue);
      viewModel.dispose();
    });
  });

  group('betöltés', () {
    test('a naptár eseményei a controllerbe kerülnek', () async {
      final calendar = FakeCalendarRepository()
        ..getResult = Ok([
          _event(
              'Analízis', DateTime(2026, 11, 5, 10), DateTime(2026, 11, 5, 12)),
        ]);

      final viewModel = CalendarViewModel(repository: calendar);
      await flush();

      final day =
          viewModel.eventController.getFilteredDayEvents(DateTime(2026, 11, 5));
      expect(day?.map((e) => e.title), ['Analízis']);
      viewModel.dispose();
    });

    test('újratöltés lecseréli a régi eseményeket', () async {
      final calendar = FakeCalendarRepository()
        ..getResult = Ok([
          _event('Régi', DateTime(2026, 11, 5, 10), DateTime(2026, 11, 5, 11)),
        ]);
      final viewModel = CalendarViewModel(repository: calendar);
      await flush();

      calendar.getResult = Ok([
        _event('Új', DateTime(2026, 11, 5, 14), DateTime(2026, 11, 5, 15)),
      ]);
      await viewModel.load.execute(true);

      final day =
          viewModel.eventController.getFilteredDayEvents(DateTime(2026, 11, 5));
      expect(day?.map((e) => e.title), ['Új']);
      viewModel.dispose();
    });

    test('hibánál megmaradnak a korábbi események', () async {
      final calendar = FakeCalendarRepository()
        ..getResult = Ok([
          _event(
              'Analízis', DateTime(2026, 11, 5, 10), DateTime(2026, 11, 5, 12)),
        ]);
      final viewModel = CalendarViewModel(repository: calendar);
      await flush();

      calendar.getResult = const Err('Nincs kapcsolat');
      await viewModel.load.execute(true);

      final day =
          viewModel.eventController.getFilteredDayEvents(DateTime(2026, 11, 5));
      expect(day?.map((e) => e.title), ['Analízis']);
      expect(viewModel.load.errorMessage, isNotNull);
      viewModel.dispose();
    });
  });

  group('nézet', () {
    test('alapból egy napot mutat', () async {
      final viewModel = CalendarViewModel(repository: FakeCalendarRepository());
      await flush();
      expect(viewModel.span, CalendarSpan.oneDay);
      viewModel.dispose();
    });

    test('váltáskor értesít, ugyanarra váltva nem', () async {
      final viewModel = CalendarViewModel(repository: FakeCalendarRepository());
      await flush();
      var notified = 0;
      viewModel.addListener(() => notified++);

      viewModel.setSpan(CalendarSpan.threeDays);
      viewModel.setSpan(CalendarSpan.threeDays);

      expect(viewModel.span, CalendarSpan.threeDays);
      expect(notified, 1);
      viewModel.dispose();
    });
  });
}
