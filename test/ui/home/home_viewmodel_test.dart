import 'package:flutter_test/flutter_test.dart';
import 'package:itk_app/domain/models/calendar_event.dart';
import 'package:itk_app/ui/home/viewmodels/home_viewmodel.dart';
import 'package:itk_app/utils/result.dart';

import '../../helpers/fake_http.dart';
import '../../helpers/fake_repositories.dart';
import '../../helpers/fixtures.dart';

CalendarEvent calendarEvent(String title, DateTime start, Duration length) =>
    CalendarEvent(title: title, start: start, end: start.add(length));

void main() {
  late FakeCalendarRepository calendar;
  late FakeAuthRepository auth;
  late FakeAbsolutoriumRepository absolutorium;

  setUp(() {
    calendar = FakeCalendarRepository();
    auth = FakeAuthRepository()..cachedUser = user();
    absolutorium = FakeAbsolutoriumRepository();
  });

  Future<HomeViewModel> create() async {
    final viewModel = HomeViewModel(
      authRepository: auth,
      calendarRepository: calendar,
      absolutoriumRepository: absolutorium,
    );
    await flush();
    return viewModel;
  }

  test('a legkorábbi, még nem véget ért esemény a következő', () async {
    final now = DateTime.now();
    calendar.getResult = Ok([
      calendarEvent('Holnapután', now.add(const Duration(days: 2)), const Duration(hours: 1)),
      calendarEvent('Tegnap', now.subtract(const Duration(days: 1)), const Duration(hours: 1)),
      calendarEvent('Holnap', now.add(const Duration(days: 1)), const Duration(hours: 1)),
    ]);

    final viewModel = await create();

    expect(viewModel.nextEvent?.title, 'Holnap');
    viewModel.dispose();
  });

  test('a most zajló esemény is számít', () async {
    final now = DateTime.now();
    calendar.getResult = Ok([
      calendarEvent('Most', now.subtract(const Duration(minutes: 30)), const Duration(hours: 1)),
      calendarEvent('Holnap', now.add(const Duration(days: 1)), const Duration(hours: 1)),
    ]);

    final viewModel = await create();

    expect(viewModel.nextEvent?.title, 'Most');
    viewModel.dispose();
  });

  test('csak múltbeli eseményeknél nincs következő', () async {
    final now = DateTime.now();
    calendar.getResult = Ok([
      calendarEvent('Tegnap', now.subtract(const Duration(days: 1)), const Duration(hours: 1)),
    ]);

    final viewModel = await create();

    expect(viewModel.nextEvent, isNull);
    viewModel.dispose();
  });

  test('a keresztnév a userből jön', () async {
    final viewModel = await create();
    expect(viewModel.firstName, 'Elek');
    viewModel.dispose();
  });
}
