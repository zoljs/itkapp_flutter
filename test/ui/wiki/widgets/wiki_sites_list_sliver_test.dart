import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:itk_app/domain/models/user_site.dart';
import 'package:itk_app/ui/core/widgets/app_spinner.dart';
import 'package:itk_app/ui/core/widgets/sliver_state_message.dart';
import 'package:itk_app/ui/wiki/widgets/site_list_card.dart';
import 'package:itk_app/ui/wiki/widgets/wiki_sites_list_sliver.dart';

UserSite _site(String name, {String? login}) => UserSite(
      login: login,
      name: name,
      url: 'https://users.itk.ppke.hu/~$name',
      tags: const ['flutter'],
      claimed: true,
    );

Future<void> _pump(
  WidgetTester tester, {
  List<UserSite> sites = const [],
  bool loading = false,
  String query = '',
  String? loadError,
  String? checkingLogin,
  ValueChanged<UserSite>? onSiteTap,
}) {
  return tester.pumpWidget(MaterialApp(
    home: Scaffold(
      body: CustomScrollView(
        slivers: [
          WikiSitesListSliver(
            sites: sites,
            loading: loading,
            query: query,
            loadError: loadError,
            checkingLogin: checkingLogin,
            onRetry: () {},
            onSiteTap: onSiteTap ?? (_) {},
          ),
        ],
      ),
    ),
  ));
}

SliverStateMessage _message(WidgetTester tester) =>
    tester.widget<SliverStateMessage>(find.byType(SliverStateMessage));

void main() {
  group('WikiSitesListSliver empty state', () {
    testWidgets('load error shows the error and retry', (tester) async {
      await _pump(tester, loadError: 'Hiba történt');

      expect(find.textContaining('Hiba történt'), findsOneWidget);
      expect(_message(tester).onRetry, isNotNull);
    });

    testWidgets('load error wins over query', (tester) async {
      await _pump(tester, loadError: 'Hiba történt', query: 'abc');

      expect(find.textContaining('Hiba történt'), findsOneWidget);
      expect(find.textContaining('Nincs találat erre'), findsNothing);
    });

    testWidgets('no sites and no query', (tester) async {
      await _pump(tester);

      expect(find.text('Még nincs oldal.'), findsOneWidget);
      expect(_message(tester).onRetry, isNull);
    });

    testWidgets('query without result, no retry', (tester) async {
      await _pump(tester, query: 'abc');

      expect(find.textContaining('Nincs találat erre'), findsOneWidget);
      expect(find.textContaining('abc'), findsOneWidget);
      expect(_message(tester).onRetry, isNull);
    });
  });

  group('WikiSitesListSliver list', () {
    testWidgets('shows a card for every site', (tester) async {
      await _pump(tester, sites: [
        _site('Anna', login: 'anna'),
        _site('Bela', login: 'bela'),
      ]);

      expect(find.byType(SiteListCard), findsNWidgets(2));
      expect(find.byType(SliverStateMessage), findsNothing);
    });

    testWidgets('tap passes the tapped site', (tester) async {
      final tapped = <UserSite>[];
      final bela = _site('Bela', login: 'bela');
      await _pump(tester,
          sites: [_site('Anna', login: 'anna'), bela], onSiteTap: tapped.add);

      await tester.tap(find.text('Bela'));

      expect(tapped, [bela]);
    });

    testWidgets('loading shows skeleton cards, not the empty state',
        (tester) async {
      await _pump(tester, loading: true);

      expect(find.byType(SiteListCard), findsNWidgets(4));
      expect(find.byType(SliverStateMessage), findsNothing);
    });
  });

  group('WikiSitesListSliver spinner', () {
    testWidgets('only the checked site shows the spinner', (tester) async {
      await _pump(
        tester,
        sites: [_site('Anna', login: 'anna'), _site('Bela', login: 'bela')],
        checkingLogin: 'bela',
      );

      expect(find.byType(AppSpinner), findsOneWidget);
    });

    testWidgets('no check running: no spinner, even without a login',
        (tester) async {
      await _pump(tester, sites: [_site('Anna'), _site('Bela')]);

      expect(find.byType(AppSpinner), findsNothing);
    });

    testWidgets('skeleton cards show no spinner', (tester) async {
      await _pump(tester, loading: true);

      expect(find.byType(AppSpinner), findsNothing);
    });
  });
}
