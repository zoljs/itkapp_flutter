import 'package:itk_app/screens/calendar_screen_test.dart';
import 'package:itk_app/screens/home_screen_test.dart';
import 'package:itk_app/screens/settings_screen.dart';
import 'package:itk_app/screens/wiki_screen.dart';
import 'package:itk_app/services/sites_service.dart';
import 'package:itk_app/theme/glass_settings.dart';
import 'package:material_ui/material_ui.dart';

import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:flutter/cupertino.dart' show CupertinoIcons;

class AppScaffold extends StatefulWidget {
  const AppScaffold({super.key});

  @override
  State<AppScaffold> createState() => _AppScaffoldState();
}

class _AppScaffoldState extends State<AppScaffold> {
  @override
  void initState() {
    super.initState();

    // Lowest point in hierarchy where it is needed, should cover all other screens as the initial load
    SitesService.instance.getMySite();
  }

  int _selectedIndex = 0;
  final List<Widget> navItems = [
    const HomeScreenTest(),
    const CalendarScreenTest(),
    const WikiScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;

    if (!isIOS) {
      return Scaffold(
        extendBody: true,
        body: navItems[_selectedIndex],
        bottomNavigationBar: _buildNavigationBar(),
      );
    }

    final scheme = Theme.of(context).colorScheme;

    return GlassScaffold(
      body: navItems[_selectedIndex],
      bottomBar: _buildCupertinoTabBar(scheme),
    );
  }

  GlassTabBar _buildCupertinoTabBar(ColorScheme scheme) {
    return GlassTabBar.minimizable(
      selectedIndex: _selectedIndex,
      onTabSelected: (i) => setState(() => _selectedIndex = i),
      selectedIconColor: scheme.primary, // a saját seed-color-od accent-je
      indicatorColor: scheme.primary.withValues(alpha: 0.20),
      tabs: const [
        GlassTab(icon: Icon(CupertinoIcons.house), label: 'Főoldal'),
        GlassTab(icon: Icon(CupertinoIcons.calendar), label: 'Naptár'),
        GlassTab(icon: Icon(CupertinoIcons.group), label: 'Wiki'),
        GlassTab(icon: Icon(CupertinoIcons.gear), label: 'Beállítások'),
      ],
      settings: kAppGlassSettings,
      quality: kAppGlassQuality,
    );
  }

  NavigationBar _buildNavigationBar() {
    return NavigationBar(
      onDestinationSelected: (value) {
        setState(() {
          _selectedIndex = value;
        });
      },
      selectedIndex: _selectedIndex,
      destinations: <Widget>[
        const NavigationDestination(
          selectedIcon: Icon(Icons.home),
          icon: Icon(Icons.home_outlined),
          label: 'Főoldal',
        ),
        const NavigationDestination(
          selectedIcon: Icon(Icons.calendar_month),
          icon: Icon(Icons.calendar_month_outlined),
          label: 'Calendar',
        ),
        NavigationDestination(
          selectedIcon: ValueListenableBuilder(
            valueListenable: SitesService.instance.mySiteNotifier,
            builder: (context, mySite, _) {
              return mySite == null
                  ? const Badge(label: Text('1'), child: Icon(Icons.groups))
                  : const Icon(Icons.groups);
            },
          ),
          icon: ValueListenableBuilder(
            valueListenable: SitesService.instance.mySiteNotifier,
            builder: (context, mySite, _) {
              return mySite == null
                  ? const Badge(
                      label: Text('1'), child: Icon(Icons.groups_outlined))
                  : const Icon(Icons.groups_outlined);
            },
          ),
          label: 'Wiki',
        ),
        const NavigationDestination(
          selectedIcon: Icon(Icons.settings),
          icon: Icon(Icons.settings_outlined),
          label: 'Beállítások',
        ),
      ],
    );
  }
}
