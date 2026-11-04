import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:itk_app/ui/core/widgets/app_filter_chip.dart';

void main() {
  Future<List<bool>> pumpAndTap(WidgetTester tester,
      {required bool selected}) async {
    final calls = <bool>[];
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: AppFilterChip(
          selected: selected,
          onSelected: calls.add,
          label: "Tárgyaim",
        ),
      ),
    ));
    await tester.tap(find.byType(FilterChip));
    return calls;
  }

  testWidgets('bekapcsolt állapotban koppintásra kikapcsolást kér',
      (tester) async {
    expect(await pumpAndTap(tester, selected: true), [false]);
  });

  testWidgets('kikapcsolt állapotban koppintásra bekapcsolást kér',
      (tester) async {
    expect(await pumpAndTap(tester, selected: false), [true]);
  });

  testWidgets('a selected értéket mutatja', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
          body: AppFilterChip(
        selected: true,
        onSelected: (_) {},
        label: 'Tárgyaim',
      )),
    ));
    expect(tester.widget<FilterChip>(find.byType(FilterChip)).selected, isTrue);
  });
}
