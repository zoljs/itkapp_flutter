import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:itk_app/ui/core/widgets/offline_banner.dart';

Future<void> _pump(WidgetTester tester, {double width = 400}) =>
    tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: width,
            child: OfflineBanner(savedAt: DateTime(2026, 11, 14, 18, 5)),
          ),
        ),
      ),
    ));

void main() {
  setUpAll(() => initializeDateFormatting('hu'));

  testWidgets('a mentési időt rövid magyar formátumban mutatja',
      (tester) async {
    await _pump(tester);

    expect(find.text('Offline. Utoljára frissítve: nov. 14. 18:05'),
        findsOneWidget);
    expect(find.byIcon(Icons.cloud_off), findsOneWidget);
  });

  testWidgets('keskeny helyen tördel, nem csordul túl', (tester) async {
    await _pump(tester, width: 160);

    expect(tester.takeException(), isNull);
  });
}
