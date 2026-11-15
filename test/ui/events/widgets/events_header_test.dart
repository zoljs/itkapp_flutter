import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:itk_app/domain/models/event.dart';
import 'package:itk_app/ui/events/widgets/events_header.dart';
import 'package:itk_app/utils/time_range.dart';

Future<void> _pump(
  WidgetTester tester, {
  required TextEditingController controller,
  bool canModerate = true,
  VoidCallback? onAction,
  ValueChanged<String>? onQueryChanged,
  bool showMySubjects = true,
  bool onlyMySubjects = false,
  ValueChanged<bool>? onMySubjectsSelected,
  Set<EventType> types = const {EventType.midterm, EventType.retake},
  Set<EventType> selectedTypes = const {},
  void Function(EventType, bool)? onTypeSelected,
  TimeRange? selectedTimeRange,
  ValueChanged<TimeRange>? onTimeRangeChanged,
}) =>
    tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: CustomScrollView(
          slivers: [
            EventsHeader(
              title: 'ZH-k',
              eventLabel: 'zh',
              canModerate: canModerate,
              onAction: onAction ?? () {},
              searchController: controller,
              onQueryChanged: onQueryChanged ?? (_) {},
              showMySubjects: showMySubjects,
              onlyMySubjects: onlyMySubjects,
              onMySubjectsSelected: onMySubjectsSelected ?? (_) {},
              types: types,
              selectedTypes: selectedTypes,
              onTypeSelected: onTypeSelected ?? (_, __) {},
              selectedTimeRange: selectedTimeRange,
              onTimeRangeChanged: onTimeRangeChanged ?? (_) {},
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 1500)),
          ],
        ),
      ),
    ));

void main() {
  setUpAll(() => initializeDateFormatting('hu'));

  late TextEditingController controller;

  setUp(() => controller = TextEditingController());
  tearDown(() => controller.dispose());

  testWidgets('a cím, a vissza gomb és a keresőmező látszik', (tester) async {
    await _pump(tester, controller: controller);

    expect(find.text('ZH-k'), findsOneWidget);
    expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);
    expect(find.text('Tárgy neve vagy kódja...'), findsOneWidget);
  });

  testWidgets('moderátornak van felvétel gomb, ami az onAction-t hívja',
      (tester) async {
    var actions = 0;
    await _pump(tester, controller: controller, onAction: () => actions++);

    await tester.tap(find.byIcon(Icons.add_rounded));
    await tester.pump();

    expect(actions, 1);
  });

  testWidgets('nem moderátornak nincs felvétel gomb', (tester) async {
    await _pump(tester, controller: controller, canModerate: false);

    expect(find.byIcon(Icons.add_rounded), findsNothing);
  });

  testWidgets('gépeléskor az onQueryChanged megkapja a szöveget',
      (tester) async {
    final queries = <String>[];
    await _pump(tester,
        controller: controller, onQueryChanged: queries.add);

    await tester.enterText(find.byType(TextField), 'anal');

    expect(queries, ['anal']);
  });

  testWidgets('az idősáv chipre koppintva az onTimeRangeChanged megkapja',
      (tester) async {
    final ranges = <TimeRange>[];
    await _pump(tester,
        controller: controller, onTimeRangeChanged: ranges.add);

    await tester.tap(find.text(TimeRange.thisMonth.label));
    await tester.pump();

    expect(ranges, [TimeRange.thisMonth]);
  });

  testWidgets('a Tárgyaim chip csak saját tárggyal látszik, és értesít',
      (tester) async {
    final calls = <bool>[];
    await _pump(tester,
        controller: controller,
        showMySubjects: false,
        onMySubjectsSelected: calls.add);
    expect(find.text('Tárgyaim'), findsNothing);

    await _pump(tester,
        controller: controller,
        showMySubjects: true,
        onMySubjectsSelected: calls.add);
    expect(find.text('Tárgyaim'), findsOneWidget);

    await tester.tap(find.text('Tárgyaim'));
    await tester.pump();

    expect(calls, [true]);
  });

  testWidgets('típus chipre koppintva az onTypeSelected a típust kapja',
      (tester) async {
    final calls = <(EventType, bool)>[];
    await _pump(tester,
        controller: controller,
        onTypeSelected: (type, selected) => calls.add((type, selected)));

    await tester.tap(find.text(EventType.retake.label));
    await tester.pump();

    expect(calls, [(EventType.retake, true)]);
  });
}
