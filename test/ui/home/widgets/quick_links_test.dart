import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:itk_app/ui/home/widgets/quick_link_tile.dart';
import 'package:itk_app/ui/home/widgets/quick_links_grid.dart';

void main() {
  testWidgets('QuickLinkTile: a felirat látszik, koppintásra az url megy',
      (tester) async {
    final taps = <String>[];
    await tester.pumpWidget(MaterialApp(
      home: Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: SizedBox(
              width: 80,
              height: 80,
              child: QuickLinkTile(
                onTap: taps.add,
                link: const QuickLink(
                    'Neptun', 'https://example.com/n', 'assets/icons/none.png'),
                scheme: Theme.of(context).colorScheme,
              ),
            ),
          ),
        ),
      ),
    ));

    expect(find.text('Neptun'), findsOneWidget);

    await tester.tap(find.text('Neptun'));
    await tester.pump();

    expect(taps, ['https://example.com/n']);
  });

  testWidgets('QuickLinksGrid: mind a négy gyorslink felirata látszik',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: QuickLinksGrid(onTap: (_) {})),
    ));

    for (final label in ['Neptun', 'ITK Space', 'TO', 'Oktatók']) {
      expect(find.text(label), findsOneWidget);
    }
  });

  testWidgets('QuickLinksGrid: a Neptun az ő url-jét adja át', (tester) async {
    final taps = <String>[];
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: QuickLinksGrid(onTap: taps.add)),
    ));

    await tester.tap(find.text('Neptun'));
    await tester.pump();

    expect(taps, ['https://neptun3.ppke.hu/hallgato_uj/login']);
  });
}
