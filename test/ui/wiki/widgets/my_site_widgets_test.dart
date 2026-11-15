import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:itk_app/domain/models/site_color.dart';
import 'package:itk_app/domain/models/user_site.dart';
import 'package:itk_app/ui/core/theme/site_colors.dart';
import 'package:itk_app/ui/core/widgets/user_avatar.dart';
import 'package:itk_app/ui/wiki/widgets/my_site_card.dart';
import 'package:itk_app/ui/wiki/widgets/my_site_color_picker.dart';
import 'package:itk_app/ui/wiki/widgets/my_site_header.dart';
import 'package:itk_app/ui/wiki/widgets/my_site_settings_group.dart';
import 'package:itk_app/ui/wiki/widgets/my_site_tags_group.dart';
import 'package:itk_app/ui/wiki/widgets/user_site_card.dart';

Widget _app(Widget child) => MaterialApp(
      home: Scaffold(body: SingleChildScrollView(child: child)),
    );

const _site = UserSite(
  login: 'perpa4',
  name: 'Teszt Elek',
  url: 'https://users.itk.ppke.hu/~perpa4',
  tags: ['Analízis'],
  color: SiteColor.green,
);

void main() {
  group('MySiteHeader', () {
    testWidgets('a login kezdőbetűje és a login értéke látszik',
        (tester) async {
      await tester.pumpWidget(_app(
        const MySiteHeader(login: 'perpa4', siteColor: SiteColor.purple),
      ));

      expect(find.byType(UserAvatar), findsOneWidget);
      expect(find.text('P'), findsOneWidget);
      expect(find.text('Adatok'), findsOneWidget);
      expect(find.text('Név és URL'), findsOneWidget);
      expect(find.text('perpa4'), findsOneWidget);
    });

    testWidgets('nincs login: U betű, üres érték', (tester) async {
      await tester.pumpWidget(_app(
        const MySiteHeader(login: null, siteColor: SiteColor.itk),
      ));

      expect(find.text('U'), findsOneWidget);
    });
  });

  group('MySiteColorPicker', () {
    testWidgets('a fejléc látszik, a színre koppintva az onSelected megkapja',
        (tester) async {
      final selections = <SiteColor>[];
      await tester.pumpWidget(_app(
        MySiteColorPicker(
          selected: SiteColor.itk,
          onSelected: selections.add,
        ),
      ));

      expect(find.text('Megjelenés'), findsOneWidget);

      // minden színhez két egymásba ágyazott AnimatedContainer tartozik,
      // a külső az, amelyik a koppintást kapja
      final swatches = find.descendant(
        of: find.byType(MySiteColorPicker),
        matching: find.byType(AnimatedContainer),
      );
      await tester.tap(swatches.at(2 * SiteColor.green.index));
      await tester.pumpAndSettle();

      expect(selections, [SiteColor.green]);
    });
  });

  group('MySiteSettingsGroup', () {
    Future<void> pump(
      WidgetTester tester, {
      bool isPublic = true,
      required ValueChanged<bool> onPublicChanged,
      VoidCallback? onOpenFileSetup,
    }) =>
        tester.pumpWidget(_app(
          MySiteSettingsGroup(
            loading: false,
            isPublic: isPublic,
            onPublicChanged: onPublicChanged,
            onOpenFileSetup: onOpenFileSetup ?? () {},
          ),
        ));

    testWidgets('a sorra koppintva az ellenkezőjére vált', (tester) async {
      final changes = <bool>[];
      await pump(tester, isPublic: true, onPublicChanged: changes.add);

      await tester.tap(find.text('Oldal publikussá tétele'));
      await tester.pump();

      expect(changes, [false]);
    });

    testWidgets('nem publikus oldalnál a koppintás publikussá teszi',
        (tester) async {
      final changes = <bool>[];
      await pump(tester, isPublic: false, onPublicChanged: changes.add);

      await tester.tap(find.text('Oldal publikussá tétele'));
      await tester.pump();

      expect(changes, [true]);
    });

    testWidgets('a fájlkezelő sora az onOpenFileSetup-ot hívja',
        (tester) async {
      var opened = 0;
      await pump(tester,
          onPublicChanged: (_) {}, onOpenFileSetup: () => opened++);

      await tester.tap(find.text('Fájlkezelő beállítása'));
      await tester.pump();

      expect(opened, 1);
    });
  });

  group('MySiteTagsGroup', () {
    setUp(() {
      // HapticFeedback talks to a platform channel that does not exist in tests.
      TestWidgetsFlutterBinding.ensureInitialized();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
              SystemChannels.platform, (call) async => null);
    });
    tearDown(() => TestDefaultBinaryMessengerBinding
        .instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null));

    Widget group({
      required List<String> tags,
      bool loading = false,
      VoidCallback? onAdd,
      ValueChanged<String>? onDelete,
    }) =>
        _app(MySiteTagsGroup(
          tags: tags,
          loading: loading,
          onAdd: onAdd ?? () {},
          onDelete: onDelete ?? (_) {},
        ));

    testWidgets('a címkék és az új hozzáadása sor látszik', (tester) async {
      await tester.pumpWidget(group(tags: ['Analízis', 'Programozás']));

      expect(find.text('Új címke hozzáadása'), findsOneWidget);
      expect(find.text('Analízis'), findsOneWidget);
      expect(find.text('Programozás'), findsOneWidget);
    });

    testWidgets('az új címke sora az onAdd-ot hívja', (tester) async {
      var adds = 0;
      await tester.pumpWidget(group(tags: const [], onAdd: () => adds++));

      await tester.tap(find.text('Új címke hozzáadása'));
      await tester.pump();

      expect(adds, 1);
    });

    testWidgets('töltés közben a valódi címkék helyett vázak látszanak',
        (tester) async {
      await tester.pumpWidget(group(tags: ['Analízis'], loading: true));

      expect(find.text('Analízis'), findsNothing);
      expect(find.text('Címke 1'), findsOneWidget);
    });

    testWidgets('balra húzva, megerősítés után a címkével hívja az onDelete-et',
        (tester) async {
      final deleted = <String>[];
      await tester.pumpWidget(
          group(tags: ['Analízis', 'Programozás'], onDelete: deleted.add));

      await tester.drag(find.text('Programozás'), const Offset(-600, 0));
      await tester.pumpAndSettle();
      expect(find.text('Címke törlése'), findsOneWidget);
      expect(deleted, isEmpty);

      await tester.tap(find.widgetWithText(FilledButton, 'Törlés'));
      await tester.pumpAndSettle();

      expect(deleted, ['Programozás']);
    });
  });

  group('MySiteCard', () {
    Widget card({
      UserSite? site,
      ValueChanged<UserSite>? onOpen,
      VoidCallback? onEdit,
    }) =>
        _app(Skeletonizer(
          enabled: false,
          child: MySiteCard(
            mySite: site,
            onOpen: onOpen ?? (_) {},
            onEdit: onEdit ?? () {},
          ),
        ));

    testWidgets('nincs saját oldal: felhívás látszik, koppintás az onEdit',
        (tester) async {
      var edits = 0;
      await tester.pumpWidget(card(onEdit: () => edits++));

      expect(find.text('Még nincs saját wiki-oldalad, hozz létre egyet!'),
          findsOneWidget);
      expect(find.text('Saját oldalam'), findsNothing);

      await tester.tap(find.byType(UserSiteCard));
      await tester.pump();

      expect(edits, 1);
    });

    testWidgets('saját oldal: a kártya az oldal színét viseli',
        (tester) async {
      await tester.pumpWidget(card(site: _site));

      expect(find.text('Saját oldalam'), findsOneWidget);
      expect(find.text('P'), findsOneWidget);
      expect(
          tester.widget<UserSiteCard>(find.byType(UserSiteCard)).color,
          SiteColor.green.color);
    });

    testWidgets('a kártyára koppintva az onOpen az oldalt kapja',
        (tester) async {
      final opened = <UserSite>[];
      await tester.pumpWidget(card(site: _site, onOpen: opened.add));

      await tester.tap(find.text('Saját oldalam'));
      await tester.pump();

      expect(opened, [_site]);
    });

    testWidgets('a szerkesztés gomb az onEdit-et hívja, az onOpen-t nem',
        (tester) async {
      var edits = 0;
      final opened = <UserSite>[];
      await tester.pumpWidget(
          card(site: _site, onOpen: opened.add, onEdit: () => edits++));

      await tester.tap(find.byTooltip('Szerkesztés'));
      await tester.pump();

      expect(edits, 1);
      expect(opened, isEmpty);
    });
  });
}
