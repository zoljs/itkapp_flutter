import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:itk_app/domain/models/event.dart';
import 'package:itk_app/ui/events/widgets/event_filter_chips.dart';
import 'package:itk_app/utils/time_range.dart';

Future<void> _pump(
  WidgetTester tester, {
  bool showMySubjects = true,
  bool onlyMySubjects = false,
  ValueChanged<bool>? onMySubjectsSelected,
  Set<EventType> types = const {EventType.midterm, EventType.retake},
  Set<EventType> selectedTypes = const {},
  void Function(EventType, bool)? onTypeSelected,
  TimeRange? selectedTimeRange,
  ValueChanged<TimeRange>? onChangedTimeRange,
}) =>
    tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: EventFilterChips(
          showMySubjects: showMySubjects,
          onlyMySubjects: onlyMySubjects,
          onMySubjectsSelected: onMySubjectsSelected ?? (_) {},
          types: types,
          selectedTypes: selectedTypes,
          onTypeSelected: onTypeSelected ?? (_, __) {},
          selectedTimeRange: selectedTimeRange,
          onChangedTimeRange: onChangedTimeRange ?? (_) {},
        ),
      ),
    ));

void main() {
  testWidgets('Tárgyaim csak akkor látszik, ha van saját tárgy',
      (tester) async {
    await _pump(tester, showMySubjects: false);
    expect(find.text('Tárgyaim'), findsNothing);

    await _pump(tester, showMySubjects: true);
    expect(find.text('Tárgyaim'), findsOneWidget);
  });

  testWidgets('több típusnál minden típushoz van chip', (tester) async {
    await _pump(tester);

    expect(find.text(EventType.midterm.label), findsOneWidget);
    expect(find.text(EventType.retake.label), findsOneWidget);
  });

  testWidgets('egyetlen típusnál nincs típus chip', (tester) async {
    await _pump(tester, types: {EventType.consultation});

    expect(find.text(EventType.consultation.label), findsNothing);
  });

  testWidgets('a kiválasztott típus chipje be van kapcsolva', (tester) async {
    await _pump(tester, selectedTypes: {EventType.retake});

    final chips =
        tester.widgetList<FilterChip>(find.byType(FilterChip)).toList();
    // Order: Tárgyaim, Ez a hét, Ez a hónap, midterm, retake
    expect(chips.map((c) => c.selected), [false, false, false, false, true]);
  });

  testWidgets('típus chip koppintás a típust és az új állapotot adja át',
      (tester) async {
    final calls = <(EventType, bool)>[];
    await _pump(tester, onTypeSelected: (t, s) => calls.add((t, s)));

    await tester.tap(find.text(EventType.retake.label));

    expect(calls, [(EventType.retake, true)]);
  });

  testWidgets('Tárgyaim koppintás az új állapotot adja át', (tester) async {
    final calls = <bool>[];
    await _pump(tester, onlyMySubjects: true, onMySubjectsSelected: calls.add);

    await tester.tap(find.text('Tárgyaim'));

    expect(calls, [false]);
  });

  testWidgets('mindkét időszak chip látszik', (tester) async {
    await _pump(tester);

    expect(find.text(TimeRange.thisWeek.label), findsOneWidget);
    expect(find.text(TimeRange.thisMonth.label), findsOneWidget);
  });

  testWidgets('az időszak chip saját tárgy és több típus nélkül is látszik',
      (tester) async {
    await _pump(tester, showMySubjects: false, types: {EventType.consultation});

    expect(find.text(TimeRange.thisWeek.label), findsOneWidget);
    expect(find.text(TimeRange.thisMonth.label), findsOneWidget);
  });

  testWidgets('a kiválasztott időszak chipje be van kapcsolva', (tester) async {
    await _pump(tester, selectedTimeRange: TimeRange.thisMonth);

    FilterChip chip(TimeRange range) =>
        tester.widget<FilterChip>(find.widgetWithText(FilterChip, range.label));

    expect(chip(TimeRange.thisMonth).selected, isTrue);
    expect(chip(TimeRange.thisWeek).selected, isFalse);
  });

  testWidgets('időszak chip koppintás az időszakot adja át', (tester) async {
    final calls = <TimeRange>[];
    await _pump(tester, onChangedTimeRange: calls.add);

    await tester.tap(find.text(TimeRange.thisWeek.label));

    expect(calls, [TimeRange.thisWeek]);
  });
}
