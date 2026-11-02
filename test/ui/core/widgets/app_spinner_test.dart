import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:itk_app/ui/core/widgets/app_spinner.dart';

Widget _app(TargetPlatform platform, {Color? color}) => MaterialApp(
      theme: ThemeData(platform: platform),
      home: Scaffold(body: Center(child: AppSpinner(color: color))),
    );

void main() {
  testWidgets('iOS-en Cupertino pörgő, a megadott színnel', (tester) async {
    await tester.pumpWidget(_app(TargetPlatform.iOS, color: Colors.black87));

    final spinner = tester.widget<CupertinoActivityIndicator>(find.byType(CupertinoActivityIndicator));
    expect(spinner.color, Colors.black87);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('Androidon Material pörgő, a megadott színnel', (tester) async {
    await tester.pumpWidget(_app(TargetPlatform.android, color: Colors.black87));

    final spinner = tester.widget<CircularProgressIndicator>(find.byType(CircularProgressIndicator));
    expect(spinner.color, Colors.black87);
    expect(find.byType(CupertinoActivityIndicator), findsNothing);
  });
}
