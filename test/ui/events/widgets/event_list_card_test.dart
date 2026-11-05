import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:itk_app/ui/events/widgets/event_list_card.dart';

import '../../../helpers/fixtures.dart';

void main() {
  /// A dismissed Dismissible must leave the tree, so [onDelete] hides the card
  /// like the real list does after the event is deleted.
  Future<List<int>> pumpCard(
    WidgetTester tester, {
    required bool deletable,
  }) async {
    final deleted = <int>[];
    var visible = true;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: StatefulBuilder(
          builder: (context, setState) => visible
              ? EventListCard(
                  event: event(id: 7, location: 'A-101'),
                  deletable: deletable,
                  confirmTitle: 'Vizsga törlése',
                  confirmMessage: 'Biztosan törlöd?',
                  onDelete: () {
                    deleted.add(7);
                    setState(() => visible = false);
                  },
                )
              : const SizedBox(),
        ),
      ),
    ));
    return deleted;
  }

  testWidgets('megjeleníti az esemény tárgyát és helyszínét', (tester) async {
    await pumpCard(tester, deletable: false);

    expect(find.text('Analízis I.'), findsOneWidget);
    expect(find.textContaining('A-101'), findsOneWidget);
  });

  testWidgets('deletable false esetén nincs csúsztatható réteg',
      (tester) async {
    await pumpCard(tester, deletable: false);

    expect(find.byType(Dismissible), findsNothing);
  });

  testWidgets('deletable true esetén csúsztatható', (tester) async {
    await pumpCard(tester, deletable: true);

    expect(find.byType(Dismissible), findsOneWidget);
  });

  testWidgets('csúsztatás és megerősítés után meghívja az onDelete-et',
      (tester) async {
    final deleted = await pumpCard(tester, deletable: true);

    await tester.drag(find.byType(Dismissible), const Offset(-500, 0));
    await tester.pumpAndSettle();
    expect(find.text('Vizsga törlése'), findsOneWidget);

    await tester.tap(find.text('Törlés'));
    await tester.pumpAndSettle();

    expect(deleted, [7]);
  });

  testWidgets('csúsztatás és mégse után nem hívja meg az onDelete-et',
      (tester) async {
    final deleted = await pumpCard(tester, deletable: true);

    await tester.drag(find.byType(Dismissible), const Offset(-500, 0));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Mégse'));
    await tester.pumpAndSettle();

    expect(deleted, isEmpty);
    expect(find.text('Analízis I.'), findsOneWidget);
  });
}
