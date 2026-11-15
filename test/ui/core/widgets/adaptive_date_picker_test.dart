import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:itk_app/ui/core/widgets/adaptive_date_picker.dart';

final _initialDate = DateTime(2026, 11, 20);
final _firstDate = DateTime(2026, 11, 1);
final _lastDate = DateTime(2026, 12, 31);
const _initialTime = TimeOfDay(hour: 14, minute: 30);

/// Opens a picker from a button and stores what it returned.
Future<void> _openPicker<T>(
  WidgetTester tester, {
  required TargetPlatform platform,
  required Future<T?> Function(BuildContext context) open,
  required void Function(T? result) onResult,
}) async {
  await tester.pumpWidget(MaterialApp(
    theme: ThemeData(platform: platform),
    home: Scaffold(
      body: Builder(
        builder: (context) => Center(
          child: ElevatedButton(
            onPressed: () async => onResult(await open(context)),
            child: const Text('Megnyit'),
          ),
        ),
      ),
    ),
  ));
  await tester.tap(find.text('Megnyit'));
  await tester.pumpAndSettle();
}

Future<DateTime?> _datePicker(BuildContext context) => showAdaptiveDatePicker(
      context: context,
      initialDate: _initialDate,
      firstDate: _firstDate,
      lastDate: _lastDate,
    );

Future<TimeOfDay?> _timePicker(BuildContext context) =>
    showAdaptiveTimePicker(context: context, initialTime: _initialTime);

void main() {
  group('showAdaptiveDatePicker', () {
    testWidgets('Android: Material párbeszédablak, OK a kezdő dátumot adja',
        (tester) async {
      DateTime? result;
      var called = false;
      await _openPicker<DateTime>(tester,
          platform: TargetPlatform.android,
          open: _datePicker,
          onResult: (value) {
            result = value;
            called = true;
          });

      expect(find.byType(DatePickerDialog), findsOneWidget);

      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      expect(called, isTrue);
      expect(result, _initialDate);
    });

    testWidgets('Android: a mégse null-t ad', (tester) async {
      DateTime? result = DateTime(2000);
      await _openPicker<DateTime>(tester,
          platform: TargetPlatform.android,
          open: _datePicker,
          onResult: (value) => result = value);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(result, isNull);
    });

    testWidgets('iOS: Cupertino lap, a Kész a kezdő dátumot adja',
        (tester) async {
      DateTime? result;
      await _openPicker<DateTime>(tester,
          platform: TargetPlatform.iOS,
          open: _datePicker,
          onResult: (value) => result = value);

      expect(find.byType(DatePickerDialog), findsNothing);
      expect(find.text('Kész'), findsOneWidget);
      expect(find.text('Mégse'), findsOneWidget);

      await tester.tap(find.text('Kész'));
      await tester.pumpAndSettle();

      expect(result, _initialDate);
    });

    testWidgets('iOS: a Mégse null-t ad', (tester) async {
      DateTime? result = DateTime(2000);
      await _openPicker<DateTime>(tester,
          platform: TargetPlatform.iOS,
          open: _datePicker,
          onResult: (value) => result = value);

      await tester.tap(find.text('Mégse'));
      await tester.pumpAndSettle();

      expect(result, isNull);
    });
  });

  group('showAdaptiveTimePicker', () {
    testWidgets('Android: Material időválasztó, OK a kezdő időt adja',
        (tester) async {
      TimeOfDay? result;
      await _openPicker<TimeOfDay>(tester,
          platform: TargetPlatform.android,
          open: _timePicker,
          onResult: (value) => result = value);

      expect(find.byType(TimePickerDialog), findsOneWidget);

      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      expect(result, _initialTime);
    });

    testWidgets('iOS: Cupertino lap, a Kész a kezdő időt adja', (tester) async {
      TimeOfDay? result;
      await _openPicker<TimeOfDay>(tester,
          platform: TargetPlatform.iOS,
          open: _timePicker,
          onResult: (value) => result = value);

      expect(find.byType(TimePickerDialog), findsNothing);

      await tester.tap(find.text('Kész'));
      await tester.pumpAndSettle();

      expect(result, _initialTime);
    });

    testWidgets('iOS: a Mégse null-t ad', (tester) async {
      TimeOfDay? result = _initialTime;
      await _openPicker<TimeOfDay>(tester,
          platform: TargetPlatform.iOS,
          open: _timePicker,
          onResult: (value) => result = value);

      await tester.tap(find.text('Mégse'));
      await tester.pumpAndSettle();

      expect(result, isNull);
    });
  });
}
