import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:itk_app/data/repositories/subjects_repository.dart';
import 'package:itk_app/domain/models/subject.dart';
import 'package:itk_app/ui/core/screens/subject_multi_picker_screen.dart';
import 'package:itk_app/ui/core/screens/subject_picker_screen.dart';
import 'package:itk_app/utils/result.dart';
import 'package:provider/provider.dart';

import '../../helpers/fake_repositories.dart';
import '../../helpers/fixtures.dart';

Widget _app(FakeSubjectsRepository subjects, Widget home) =>
    Provider<SubjectsRepository>.value(
      value: subjects,
      child: MaterialApp(home: home),
    );

/// Hosts [picker] on a pushed route, so popping it leads back to a page.
Widget _pushed(FakeSubjectsRepository subjects, Widget picker,
        {void Function(Subject?)? onResult}) =>
    _app(
      subjects,
      Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: ElevatedButton(
              onPressed: () async {
                final result = await Navigator.push<Subject>(
                  context,
                  MaterialPageRoute(builder: (_) => picker),
                );
                onResult?.call(result);
              },
              child: const Text('Megnyit'),
            ),
          ),
        ),
      ),
    );

void main() {
  late FakeSubjectsRepository subjects;

  setUp(() {
    subjects = FakeSubjectsRepository()
      ..getResult = const Ok([analysis, programming]);
  });

  group('SubjectPickerScreen', () {
    testWidgets('a tárgyak neve és kódja látszik', (tester) async {
      await tester.pumpWidget(_app(subjects, const SubjectPickerScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Tárgy'), findsOneWidget);
      expect(find.text('Analízis I.'), findsOneWidget);
      expect(find.text('ITK101'), findsOneWidget);
      expect(find.text('Programozás alapjai'), findsOneWidget);
      expect(find.text('ITK202'), findsOneWidget);
    });

    testWidgets('a kiválasztott tárgy mellett pipa van', (tester) async {
      await tester.pumpWidget(
          _app(subjects, SubjectPickerScreen(selectedId: programming.id)));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.check_rounded), findsOneWidget);
    });

    testWidgets('a keresés névre és kódra szűr', (tester) async {
      await tester.pumpWidget(_app(subjects, const SubjectPickerScreen()));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'programozás');
      await tester.pump();
      expect(find.text('Analízis I.'), findsNothing);
      expect(find.text('Programozás alapjai'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'itk101');
      await tester.pump();
      expect(find.text('Analízis I.'), findsOneWidget);
      expect(find.text('Programozás alapjai'), findsNothing);
    });

    testWidgets('hiba esetén üzenet és Újra gomb, ami újratölt',
        (tester) async {
      subjects.getResult = const Err('Nem érhető el a szerver.');
      await tester.pumpWidget(_app(subjects, const SubjectPickerScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Nem érhető el a szerver.'), findsOneWidget);
      expect(find.text('Analízis I.'), findsNothing);

      subjects.getResult = const Ok([analysis]);
      await tester.tap(find.text('Újra'));
      await tester.pumpAndSettle();

      expect(find.text('Nem érhető el a szerver.'), findsNothing);
      expect(find.text('Analízis I.'), findsOneWidget);
    });

    testWidgets('a tárgyra koppintva a tárgy a visszatérési érték',
        (tester) async {
      Subject? result;
      await tester.pumpWidget(_pushed(
        subjects,
        const SubjectPickerScreen(),
        onResult: (value) => result = value,
      ));
      await tester.tap(find.text('Megnyit'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Programozás alapjai'));
      await tester.pumpAndSettle();

      expect(result?.id, programming.id);
      expect(find.text('Megnyit'), findsOneWidget);
    });
  });

  group('SubjectMultiPickerScreen', () {
    Widget screen({
      List<String> currentTags = const [],
      ValueChanged<List<String>>? onSave,
    }) =>
        _app(
          subjects,
          SubjectMultiPickerScreen(
            currentTags: currentTags,
            onSave: onSave ?? (_) {},
          ),
        );

    testWidgets('a már kiválasztott címkék be vannak jelölve', (tester) async {
      await tester.pumpWidget(screen(currentTags: ['Analízis I.']));
      await tester.pumpAndSettle();

      expect(find.text('Címkék'), findsOneWidget);
      expect(find.byIcon(CupertinoIcons.checkmark_circle_fill),
          findsOneWidget);
      expect(find.byIcon(CupertinoIcons.circle), findsOneWidget);
    });

    testWidgets('koppintásra a tárgy ki- majd visszakapcsolható',
        (tester) async {
      await tester.pumpWidget(screen());
      await tester.pumpAndSettle();
      expect(find.byIcon(CupertinoIcons.checkmark_circle_fill), findsNothing);

      await tester.tap(find.text('Programozás alapjai'));
      await tester.pump();
      expect(find.byIcon(CupertinoIcons.checkmark_circle_fill),
          findsOneWidget);

      await tester.tap(find.text('Programozás alapjai'));
      await tester.pump();
      expect(find.byIcon(CupertinoIcons.checkmark_circle_fill), findsNothing);
    });

    testWidgets('mentéskor az onSave a kiválasztott tárgyneveket kapja',
        (tester) async {
      List<String>? saved;
      await tester.pumpWidget(_pushed(
        subjects,
        SubjectMultiPickerScreen(
          currentTags: const ['Analízis I.'],
          onSave: (tags) => saved = tags,
        ),
      ));
      await tester.tap(find.text('Megnyit'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Programozás alapjai'));
      await tester.pump();
      await tester.tap(find.byIcon(Icons.check_rounded));
      await tester.pumpAndSettle();

      expect(saved, unorderedEquals(['Analízis I.', 'Programozás alapjai']));
    });
  });
}
