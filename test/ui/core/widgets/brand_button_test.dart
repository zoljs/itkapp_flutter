import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:itk_app/ui/core/widgets/app_pressable.dart';
import 'package:itk_app/ui/core/widgets/app_spinner.dart';
import 'package:itk_app/ui/core/widgets/brand_button.dart';

Future<void> _pump(
  WidgetTester tester, {
  VoidCallback? onTap,
  bool loading = false,
}) =>
    tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Center(
          child: BrandButton(
            onTap: onTap,
            loading: loading,
            child: const Text('Mentés'),
          ),
        ),
      ),
    ));

double _opacity(WidgetTester tester) => tester
    .widget<AnimatedOpacity>(find.descendant(
      of: find.byType(BrandButton),
      matching: find.byType(AnimatedOpacity),
    ))
    .opacity;

// The spinner animates forever, so these tests use pump(), not pumpAndSettle().
void main() {
  testWidgets('tap calls onTap', (tester) async {
    var taps = 0;
    await _pump(tester, onTap: () => taps++);
    await tester.tap(find.byType(BrandButton));
    await tester.pump();
    expect(taps, 1);
  });

  testWidgets('loading shows the spinner instead of the child',
      (tester) async {
    await _pump(tester, onTap: () {}, loading: true);
    expect(find.byType(AppSpinner), findsOneWidget);
    expect(find.text('Mentés'), findsNothing);
  });

  testWidgets('loading ignores taps', (tester) async {
    var taps = 0;
    await _pump(tester, onTap: () => taps++, loading: true);
    await tester.tap(find.byType(BrandButton));
    await tester.pump();
    expect(taps, 0);
  });

  testWidgets('disabled is faded', (tester) async {
    await _pump(tester);
    expect(_opacity(tester), AppPressable.disabledOpacity);
  });

  testWidgets('loading is not faded', (tester) async {
    await _pump(tester, onTap: () {}, loading: true);
    expect(_opacity(tester), 1.0);
  });
}
