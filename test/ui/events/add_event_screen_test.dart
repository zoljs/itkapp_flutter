import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:itk_app/data/repositories/event_repository.dart';
import 'package:itk_app/data/repositories/subjects_repository.dart';
import 'package:itk_app/domain/models/event.dart';
import 'package:itk_app/ui/core/widgets/grouped_list.dart';
import 'package:itk_app/ui/events/add_event_screen.dart';
import 'package:itk_app/utils/result.dart';
import 'package:provider/provider.dart';

import '../../helpers/fake_repositories.dart';
import '../../helpers/fixtures.dart';

Finder _tile(String title) => find.widgetWithText(SettingsTile, title);

void main() {
  late FakeEventRepository events;
  late FakeSubjectsRepository subjects;

  setUp(() {
    events = FakeEventRepository();
    subjects = FakeSubjectsRepository()
      ..getResult = const Ok([analysis, programming]);
  });

  Future<void> pump(
    WidgetTester tester, {
    Set<EventType> types = const {EventType.midterm},
  }) =>
      tester.pumpWidget(MultiProvider(
        providers: [
          Provider<EventRepository>.value(value: events),
          Provider<SubjectsRepository>.value(value: subjects),
        ],
        child: MaterialApp(
          home: AddEventScreen(types: types, eventLabel: 'zh'),
        ),
      ));

  Future<void> pickSubject(WidgetTester tester, String name) async {
    await tester.tap(_tile('Tárgy'));
    await tester.pumpAndSettle();
    await tester.tap(find.text(name));
    await tester.pumpAndSettle();
  }

  Future<void> pickDate(WidgetTester tester) async {
    await tester.tap(_tile('Dátum'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
  }

  Future<void> pickTime(WidgetTester tester) async {
    await tester.tap(_tile('Kezdés'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
  }

  Future<void> save(WidgetTester tester) async {
    await tester.tap(find.byIcon(Icons.check));
    await tester.pumpAndSettle();
  }

  testWidgets('induláskor mindhárom kötelező mező Válassz, a mentés tiltott',
      (tester) async {
    await pump(tester);

    expect(find.text('Új zh'), findsOneWidget);
    expect(find.text('Válassz'), findsNWidgets(3));

    await save(tester);

    expect(events.lastAdd, isNull);
  });

  testWidgets('egy típusnál nincs típusválasztó, többnél van', (tester) async {
    await pump(tester);
    expect(find.byType(SegmentedButton<EventType>), findsNothing);

    await pump(tester, types: {EventType.midterm, EventType.retake});
    expect(find.byType(SegmentedButton<EventType>), findsOneWidget);
    expect(find.text(EventType.retake.label), findsOneWidget);
  });

  testWidgets('a tárgyválasztó a kiválasztott tárgy nevét írja a sorba',
      (tester) async {
    await pump(tester);

    await pickSubject(tester, 'Programozás alapjai');

    expect(find.text('Válassz'), findsNWidgets(2));
    expect(
        find.descendant(
            of: _tile('Tárgy'), matching: find.text('Programozás alapjai')),
        findsOneWidget);
  });

  testWidgets('az időválasztó a kezdést 8:00-ról indítja', (tester) async {
    await pump(tester);

    await pickTime(tester);

    expect(find.text('8:00 AM'), findsOneWidget);
    expect(find.text('Válassz'), findsNWidgets(2));
  });

  testWidgets('hiányzó időpontnál a mentés nem küld semmit', (tester) async {
    await pump(tester);

    await pickSubject(tester, 'Analízis I.');
    await pickDate(tester);
    await save(tester);

    expect(events.lastAdd, isNull);
  });

  testWidgets('kitöltve a mentés a repository-t hívja a megadott adatokkal',
      (tester) async {
    await pump(tester, types: {EventType.midterm, EventType.retake});

    await pickSubject(tester, 'Programozás alapjai');
    await tester.tap(find.text(EventType.retake.label));
    await tester.pumpAndSettle();
    await pickDate(tester);
    await pickTime(tester);
    await tester.enterText(find.byType(TextField), '  201-es terem ');
    await save(tester);

    final add = events.lastAdd;
    expect(add, isNotNull);
    expect(add!.subjectId, programming.id);
    expect(add.type, EventType.retake);
    expect(add.location, '201-es terem');
    expect(add.startsAt.hour, 8);
    expect(add.startsAt.minute, 0);
    expect(DateUtils.isSameDay(add.startsAt, DateTime.now()), isTrue);
  });

  testWidgets('üres helyszín null-ként megy el', (tester) async {
    await pump(tester);

    await pickSubject(tester, 'Analízis I.');
    await pickDate(tester);
    await pickTime(tester);
    await save(tester);

    expect(events.lastAdd?.location, isNull);
    expect(events.lastAdd?.type, EventType.midterm);
  });

  testWidgets('sikertelen mentés: a hibaüzenet megjelenik', (tester) async {
    events.addResult = const Err('Nem sikerült menteni.');
    await pump(tester);

    await pickSubject(tester, 'Analízis I.');
    await pickDate(tester);
    await pickTime(tester);
    await save(tester);

    expect(find.text('Nem sikerült menteni.'), findsOneWidget);
  });
}
