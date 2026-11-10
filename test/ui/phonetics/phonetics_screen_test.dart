import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:itk_app/ui/phonetics/phonetics_screen.dart';
import 'package:itk_app/ui/phonetics/widgets/consonant_chart.dart';
import 'package:itk_app/ui/phonetics/widgets/vowel_chart.dart';

void main() {
  Future<void> pumpScreen(WidgetTester tester) async {
    // Tall surface: the details sit below the chart in a lazy ListView.
    await tester.binding.setSurfaceSize(const Size(400, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(const MaterialApp(home: PhoneticsScreen()));
  }

  testWidgets('alapból a magánhangzó ábra látszik', (tester) async {
    await pumpScreen(tester);

    expect(find.byType(VowelChart), findsOneWidget);
    expect(find.byType(ConsonantChart), findsNothing);
    expect(find.text('Koppints egy hangra az ábrán a részletekért.'),
        findsOneWidget);
  });

  testWidgets('a szegmensre koppintva a mássalhangzó ábra jelenik meg',
      (tester) async {
    await pumpScreen(tester);

    await tester.tap(find.text('Mássalhangzók'));
    await tester.pumpAndSettle();

    expect(find.byType(ConsonantChart), findsOneWidget);
    expect(find.byType(VowelChart), findsNothing);
  });

  testWidgets('magánhangzó cellára koppintva a pár mindkét hangja megjelenik',
      (tester) async {
    await pumpScreen(tester);

    await tester.tap(find.text('i  iː'));
    await tester.pumpAndSettle();

    expect(find.text('kis'), findsOneWidget);
    expect(find.text('víz'), findsOneWidget);
    expect(find.text('Koppints egy hangra az ábrán a részletekért.'),
        findsNothing);
  });

  testWidgets('mássalhangzó cellára koppintva a pár mindkét hangja megjelenik',
      (tester) async {
    await pumpScreen(tester);
    await tester.tap(find.text('Mássalhangzók'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('p'));
    await tester.pumpAndSettle();

    expect(find.text('pap'), findsOneWidget);
    expect(find.text('bab'), findsOneWidget);
    expect(find.text('Zöngétlen bilabiális zárhang'), findsOneWidget);
  });

  testWidgets('a kijelölt cellára újra koppintva eltűnnek a részletek',
      (tester) async {
    await pumpScreen(tester);

    await tester.tap(find.text('i  iː'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('i  iː'));
    await tester.pumpAndSettle();

    expect(find.text('kis'), findsNothing);
  });
}
