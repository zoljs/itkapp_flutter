import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:itk_app/ui/core/widgets/navbar.dart';

const _items = [
  NavBarItem(
      icon: Icons.home_outlined,
      selectedIcon: Icons.home_rounded,
      label: 'Főoldal'),
  NavBarItem(
      icon: Icons.calendar_month_outlined,
      selectedIcon: Icons.calendar_month_rounded,
      label: 'Naptár'),
];

Future<void> _pump(
  WidgetTester tester, {
  int selectedIndex = 0,
  ValueChanged<int>? onTap,
  bool reduceMotion = false,
}) =>
    tester.pumpWidget(MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(disableAnimations: reduceMotion),
        child: Scaffold(
          bottomNavigationBar: AppNavBar(
            items: _items,
            selectedIndex: selectedIndex,
            onTap: onTap ?? (_) {},
          ),
        ),
      ),
    ));

void main() {
  testWidgets('a kiválasztott fül teli ikont kap, a többi körvonalasat',
      (tester) async {
    await _pump(tester, selectedIndex: 1);
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.calendar_month_rounded), findsOneWidget);
    expect(find.byIcon(Icons.home_outlined), findsOneWidget);
    expect(find.byIcon(Icons.home_rounded), findsNothing);
  });

  testWidgets('koppintás a fül indexét adja vissza', (tester) async {
    int? tapped;
    await _pump(tester, onTap: (i) => tapped = i);

    await tester.tap(find.text('Naptár'));
    expect(tapped, 1);
  });

  testWidgets('váltáskor egy pillanatig mindkét ikon látszik, utána csak az új',
      (tester) async {
    await _pump(tester, selectedIndex: 0);
    await tester.pumpAndSettle();

    await _pump(tester, selectedIndex: 1);
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byIcon(Icons.calendar_month_outlined), findsOneWidget);
    expect(find.byIcon(Icons.calendar_month_rounded), findsOneWidget);

    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.calendar_month_outlined), findsNothing);
  });

  testWidgets('csökkentett mozgásnál azonnal vált', (tester) async {
    await _pump(tester, selectedIndex: 0, reduceMotion: true);
    await _pump(tester, selectedIndex: 1, reduceMotion: true);
    await tester.pump();

    expect(find.byIcon(Icons.calendar_month_outlined), findsNothing);
    expect(find.byIcon(Icons.calendar_month_rounded), findsOneWidget);
  });

  testWidgets('képernyőolvasó gombként és kiválasztottként látja a fület',
      (tester) async {
    final handle = tester.ensureSemantics();
    await _pump(tester, selectedIndex: 1);

    expect(
      tester.getSemantics(find.bySemanticsLabel('Naptár')),
      matchesSemantics(
        label: 'Naptár',
        isButton: true,
        isSelected: true,
        hasSelectedState: true,
        hasTapAction: true,
      ),
    );
    handle.dispose();
  });

  testWidgets('csak tényleges fülváltáskor van haptikus visszajelzés',
      (tester) async {
    final calls = <MethodCall>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'HapticFeedback.vibrate') calls.add(call);
        return null;
      },
    );
    addTearDown(() => tester.binding.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null));

    await _pump(tester, selectedIndex: 0);
    await tester.tap(find.text('Főoldal'));
    expect(calls, isEmpty);

    await tester.tap(find.text('Naptár'));
    expect(calls, hasLength(1));
  });

  group('pill', () {
    Rect pill(WidgetTester tester) =>
        tester.getRect(find.byKey(SlidingTabPill.pillKey));

    testWidgets('a kiválasztott fül mögött áll', (tester) async {
      await _pump(tester, selectedIndex: 1);
      await tester.pumpAndSettle();

      final tab = tester.getRect(find.byType(NavBarTab).at(1));
      expect(pill(tester).center.dx, closeTo(tab.center.dx, 0.5));
    });

    testWidgets('váltás közben megnyúlik, a végén egy fül széles',
        (tester) async {
      await _pump(tester, selectedIndex: 0);
      await tester.pumpAndSettle();
      final restingWidth = pill(tester).width;

      await _pump(tester, selectedIndex: 1);
      await tester.pump(const Duration(milliseconds: 150));
      expect(pill(tester).width, greaterThan(restingWidth));

      await tester.pumpAndSettle();
      expect(pill(tester).width, closeTo(restingWidth, 0.5));
      final tab = tester.getRect(find.byType(NavBarTab).at(1));
      expect(pill(tester).center.dx, closeTo(tab.center.dx, 0.5));
    });

    testWidgets('csökkentett mozgásnál azonnal az új fülre ugrik',
        (tester) async {
      await _pump(tester, selectedIndex: 0, reduceMotion: true);
      await _pump(tester, selectedIndex: 1, reduceMotion: true);
      await tester.pump();

      final tab = tester.getRect(find.byType(NavBarTab).at(1));
      expect(pill(tester).center.dx, closeTo(tab.center.dx, 0.5));
    });
  });

  group('pop', () {
    double scaleOf(WidgetTester tester, int tab) {
      final transform = tester.widget<Transform>(find
          .descendant(
            of: find.byType(PopOnSelect).at(tab),
            matching: find.byType(Transform),
          )
          .first);
      return transform.transform.getMaxScaleOnAxis();
    }

    testWidgets('csak az újonnan kiválasztott ikon ugrik meg', (tester) async {
      await _pump(tester, selectedIndex: 0);
      await tester.pumpAndSettle();

      await _pump(tester, selectedIndex: 1);
      await tester.pump(const Duration(milliseconds: 100));

      expect(scaleOf(tester, 1), greaterThan(1.0));
      expect(scaleOf(tester, 0), 1.0);

      await tester.pumpAndSettle();
      expect(scaleOf(tester, 1), closeTo(1.0, 0.001));
    });
  });
}
