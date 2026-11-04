import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:itk_app/domain/models/event.dart';
import 'package:itk_app/ui/events/widgets/event_filter_chips.dart';

Future<void> _pump(
  WidgetTester tester, {
  bool showMySubjects = true,
  bool onlyMySubjects = false,
  ValueChanged<bool>? onMySubjectsSelected,
  Set<EventType> types = const {EventType.midterm, EventType.retake},
  Set<EventType> selectedTypes = const {},
  void Function(EventType, bool)? onTypeSelected,
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
        ),
      ),
    ));

void main() {
  testWidgets('Tárgyaim csak akkor látszik, ha van saját tárgy', (tester) async {
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

    final chips = tester
        .widgetList<FilterChip>(find.byType(FilterChip))
        .toList();
    // Order: Tárgyaim, midterm, retake
    expect(chips.map((c) => c.selected), [false, false, true]);
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
}
