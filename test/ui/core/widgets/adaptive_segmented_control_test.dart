import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:itk_app/ui/core/widgets/adaptive_segmented_control.dart';

Future<void> _pump(
  WidgetTester tester, {
  required TargetPlatform platform,
  required ValueChanged<int> onChanged,
  int selected = 0,
}) =>
    tester.pumpWidget(MaterialApp(
      theme: ThemeData(platform: platform),
      home: Scaffold(
        body: Center(
          child: AdaptiveSegmentedControl<int>(
            values: const [0, 1, 2],
            selected: selected,
            labelOf: (value) => 'Opció $value',
            onChanged: onChanged,
          ),
        ),
      ),
    ));

void main() {
  group('Android', () {
    testWidgets('SegmentedButton, minden felirattal', (tester) async {
      await _pump(tester, platform: TargetPlatform.android, onChanged: (_) {});

      expect(find.byType(SegmentedButton<int>), findsOneWidget);
      expect(find.byType(CupertinoSlidingSegmentedControl<int>), findsNothing);
      for (final label in ['Opció 0', 'Opció 1', 'Opció 2']) {
        expect(find.text(label), findsOneWidget);
      }
    });

    testWidgets('másik szegmensre koppintva az onChanged az értéket kapja',
        (tester) async {
      final changes = <int>[];
      await _pump(tester,
          platform: TargetPlatform.android, onChanged: changes.add);

      await tester.tap(find.text('Opció 2'));
      await tester.pumpAndSettle();

      expect(changes, [2]);
    });
  });

  group('iOS', () {
    testWidgets('Cupertino csúszka, minden felirattal', (tester) async {
      await _pump(tester, platform: TargetPlatform.iOS, onChanged: (_) {});

      expect(find.byType(CupertinoSlidingSegmentedControl<int>),
          findsOneWidget);
      expect(find.byType(SegmentedButton<int>), findsNothing);
      for (final label in ['Opció 0', 'Opció 1', 'Opció 2']) {
        expect(find.text(label), findsOneWidget);
      }
    });

    testWidgets('másik szegmensre koppintva az onChanged az értéket kapja',
        (tester) async {
      final changes = <int>[];
      await _pump(tester, platform: TargetPlatform.iOS, onChanged: changes.add);

      await tester.tap(find.text('Opció 1'));
      await tester.pumpAndSettle();

      expect(changes, [1]);
    });
  });
}
