import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:itk_app/ui/calendar/viewmodels/calendar_viewmodel.dart';
import 'package:itk_app/ui/calendar/widgets/calendar_header.dart';

Future<void> _pump(
  WidgetTester tester, {
  DateTime? firstDay,
  CalendarSpan span = CalendarSpan.oneDay,
  bool showsToday = false,
  String? errorMessage,
}) =>
    tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: CalendarHeader(
          firstDay: firstDay ?? DateTime(2026, 11, 5),
          rollForward: true,
          span: span,
          showsToday: showsToday,
          errorMessage: errorMessage,
          onRefresh: () {},
          onPickDate: () {},
        ),
      ),
    ));

void main() {
  setUpAll(() => initializeDateFormatting('hu'));

  group('titleFor', () {
    test('egy nap: rövid hónap és nap', () {
      expect(CalendarHeader.titleFor(DateTime(2026, 11, 5), 1), 'nov. 5.');
    });

    test('több nap egy hónapon belül: tartomány egy hónapnévvel', () {
      expect(CalendarHeader.titleFor(DateTime(2026, 11, 5), 3), 'nov. 5-7.');
    });

    test('hónapon átnyúló tartomány: mindkét hónap rövid névvel', () {
      final title = CalendarHeader.titleFor(DateTime(2026, 10, 30), 3);
      expect(title, startsWith('okt'));
      expect(title, contains(' - '));
      expect(title, endsWith('1.'));
    });

    test('évhatáron is a helyes napot adja', () {
      expect(CalendarHeader.titleFor(DateTime(2026, 12, 30), 3),
          endsWith('jan. 1.'));
    });
  });

  testWidgets('a Ma jelzés csak akkor látszik, ha a mai nap látható',
      (tester) async {
    await _pump(tester, showsToday: false);
    expect(find.textContaining('· Ma'), findsNothing);

    await _pump(tester, showsToday: true);
    expect(find.textContaining('· Ma'), findsOneWidget);
  });

  testWidgets('hibaüzenet csak hiba esetén jelenik meg', (tester) async {
    await _pump(tester);
    expect(find.text('Nincs kapcsolat'), findsNothing);

    await _pump(tester, errorMessage: 'Nincs kapcsolat');
    expect(find.text('Nincs kapcsolat'), findsOneWidget);
  });
}
