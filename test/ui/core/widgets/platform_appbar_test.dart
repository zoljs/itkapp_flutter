// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:itk_app/ui/core/widgets/platform_appbar.dart';

Future<void> _pump(
  WidgetTester tester, {
  Widget? title,
  List<Widget>? actions,
  Widget? bottom,
  Widget? centeredWidget,
  bool hasBackButton = false,
}) =>
    tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: CustomScrollView(
          slivers: [
            ShrinkingSliverAppBar(
              title: title,
              actions: actions,
              bottom: bottom,
              centeredWidget: centeredWidget,
              hasBackButton: hasBackButton,
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 1000)),
          ],
        ),
      ),
    ));

void main() {
  testWidgets('a cím, a műveletek, az alsó és a középre tett elem látszik',
      (tester) async {
    await _pump(
      tester,
      title: const Text('Wiki'),
      actions: const [Icon(Icons.add)],
      bottom: const Text('Alsó sáv'),
      centeredWidget: const Text('Középen'),
    );

    expect(find.text('Wiki'), findsOneWidget);
    expect(find.byIcon(Icons.add), findsOneWidget);
    expect(find.text('Alsó sáv'), findsOneWidget);
    expect(find.text('Középen'), findsOneWidget);
  });

  testWidgets('alapból nincs vissza gomb', (tester) async {
    await _pump(tester, title: const Text('Wiki'));

    expect(find.byIcon(Icons.arrow_back_rounded), findsNothing);
  });

  testWidgets('hasBackButton: van vissza gomb, és visszalép', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (_) => Scaffold(
                    body: CustomScrollView(
                      slivers: [
                        const ShrinkingSliverAppBar(
                          title: Text('Második'),
                          hasBackButton: true,
                        ),
                        const SliverToBoxAdapter(child: SizedBox(height: 1000)),
                      ],
                    ),
                  ),
                ),
              ),
              child: const Text('Tovább'),
            ),
          ),
        ),
      ),
    ));

    await tester.tap(find.text('Tovább'));
    await tester.pumpAndSettle();
    expect(find.text('Második'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_back_rounded));
    await tester.pumpAndSettle();

    expect(find.text('Második'), findsNothing);
    expect(find.text('Tovább'), findsOneWidget);
  });
}
