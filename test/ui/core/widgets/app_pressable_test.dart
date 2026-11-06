import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:itk_app/ui/core/widgets/app_pressable.dart';

Future<void> _pump(
  WidgetTester tester, {
  VoidCallback? onTap,
  bool reduceMotion = false,
  bool inList = false,
}) {
  final pressable = AppPressable(
    onTap: onTap,
    semanticLabel: 'Gomb',
    child: const SizedBox(width: 100, height: 48),
  );
  return tester.pumpWidget(MaterialApp(
    home: MediaQuery(
      data: MediaQueryData(disableAnimations: reduceMotion),
      child: Scaffold(
        body: inList
            ? ListView(children: [pressable, const SizedBox(height: 2000)])
            : Center(child: pressable),
      ),
    ),
  ));
}

AnimatedScale _scale(WidgetTester tester) => tester.widget(find.descendant(
      of: find.byType(AppPressable),
      matching: find.byType(AnimatedScale),
    ));

void main() {
  testWidgets('tap calls onTap', (tester) async {
    var taps = 0;
    await _pump(tester, onTap: () => taps++);
    await tester.tap(find.byType(AppPressable));
    await tester.pumpAndSettle();
    expect(taps, 1);
  });

  testWidgets('shrinks while pressed and restores on release', (tester) async {
    await _pump(tester, onTap: () {});
    final gesture =
        await tester.startGesture(tester.getCenter(find.byType(AppPressable)));
    await tester.pump(kPressTimeout);
    await tester.pump();
    expect(_scale(tester).scale, 0.96);
    await gesture.up();
    await tester.pumpAndSettle();
    expect(_scale(tester).scale, 1);
  });

  testWidgets('disabled does not shrink', (tester) async {
    await _pump(tester);
    final gesture =
        await tester.startGesture(tester.getCenter(find.byType(AppPressable)));
    await tester.pump(kPressTimeout);
    await tester.pump();
    expect(_scale(tester).scale, 1);
    await gesture.up();
    await tester.pumpAndSettle();
  });

  testWidgets('scrolling a list does not press', (tester) async {
    var taps = 0;
    await _pump(tester, onTap: () => taps++, inList: true);
    final gesture =
        await tester.startGesture(tester.getCenter(find.byType(AppPressable)));
    await gesture.moveBy(const Offset(0, -50));
    await tester.pump(kPressTimeout);
    await tester.pump();
    expect(_scale(tester).scale, 1);
    await gesture.up();
    await tester.pumpAndSettle();
    expect(taps, 0);
  });

  testWidgets('reduce motion switches instantly', (tester) async {
    await _pump(tester, onTap: () {}, reduceMotion: true);
    expect(_scale(tester).duration, Duration.zero);
  });

  testWidgets('is a labeled button with a tap action', (tester) async {
    final handle = tester.ensureSemantics();
    await _pump(tester, onTap: () {});
    expect(
      tester.getSemantics(find.byType(AppPressable)),
      isSemantics(
        label: 'Gomb',
        isButton: true,
        isEnabled: true,
        hasTapAction: true,
      ),
    );
    handle.dispose();
  });
}
