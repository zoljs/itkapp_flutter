import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:itk_app/domain/models/site_color.dart';
import 'package:itk_app/domain/models/user_site.dart';
import 'package:itk_app/ui/core/theme/site_colors.dart';
import 'package:itk_app/ui/core/widgets/app_spinner.dart';
import 'package:itk_app/ui/wiki/widgets/site_list_card.dart';
import 'package:itk_app/ui/wiki/widgets/user_site_card.dart';

UserSite _site({
  bool claimed = true,
  List<String> tags = const ['flutter', 'dart'],
  SiteColor color = SiteColor.purple,
}) =>
    UserSite(
      login: 'kovacs',
      name: 'Kovács Anna',
      url: 'https://users.itk.ppke.hu/~kovacs',
      tags: tags,
      claimed: claimed,
      color: color,
    );

Future<void> _pump(
  WidgetTester tester,
  UserSite site, {
  bool checking = false,
  VoidCallback? onTap,
}) =>
    tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SiteListCard(
          site: site,
          checking: checking,
          onTap: onTap ?? () {},
        ),
      ),
    ));

void main() {
  testWidgets('megjeleníti a nevet, a hosztot és a címkéket', (tester) async {
    await _pump(tester, _site());

    expect(find.text('Kovács Anna'), findsOneWidget);
    expect(find.text('users.itk.ppke.hu'), findsOneWidget);
    expect(find.text('flutter'), findsOneWidget);
    expect(find.text('dart'), findsOneWidget);
  });

  testWidgets('legfeljebb 4 címkét mutat', (tester) async {
    await _pump(tester, _site(tags: ['a', 'b', 'c', 'd', 'e', 'f']));

    for (final tag in ['a', 'b', 'c', 'd']) {
      expect(find.text(tag), findsOneWidget);
    }
    expect(find.text('e'), findsNothing);
    expect(find.text('f'), findsNothing);
  });

  testWidgets('koppintásra meghívja az onTap-ot', (tester) async {
    var taps = 0;
    await _pump(tester, _site(), onTap: () => taps++);

    await tester.tap(find.byType(SiteListCard));

    expect(taps, 1);
  });

  testWidgets('ellenőrzés közben pörgőt mutat nyíl helyett', (tester) async {
    await _pump(tester, _site(), checking: true);

    expect(find.byType(AppSpinner), findsOneWidget);
    expect(find.byIcon(Icons.arrow_forward_rounded), findsNothing);
  });

  testWidgets('ellenőrzés nélkül nyilat mutat, pörgő nélkül', (tester) async {
    await _pump(tester, _site());

    expect(find.byIcon(Icons.arrow_forward_rounded), findsOneWidget);
    expect(find.byType(AppSpinner), findsNothing);
  });

  testWidgets('a claimed oldal a saját színét kapja', (tester) async {
    await _pump(tester, _site(color: SiteColor.purple));

    final card = tester.widget<UserSiteCard>(find.byType(UserSiteCard));
    expect(card.color, SiteColor.purple.color);
  });

  testWidgets('a nem claimed oldal szürke', (tester) async {
    await _pump(tester, _site(claimed: false, color: SiteColor.purple));

    final card = tester.widget<UserSiteCard>(find.byType(UserSiteCard));
    expect(card.color, Colors.grey);
  });
}
