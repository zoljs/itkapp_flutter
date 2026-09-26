import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:itk_app/screens/calendar_screen_test.dart';
import 'package:itk_app/screens/home_screen_test.dart';
import 'package:itk_app/screens/settings_screen.dart';
import 'package:itk_app/screens/wiki_screen.dart';
import 'package:itk_app/services/sites_service.dart';
import 'package:flutter/material.dart';

class AppScaffold extends StatefulWidget {
  const AppScaffold({super.key});

  @override
  State<AppScaffold> createState() => _AppScaffoldState();
}

class _AppScaffoldState extends State<AppScaffold> {
  @override
  void initState() {
    super.initState();
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
    return ValueListenableBuilder(
      valueListenable: SitesService.instance.mySiteNotifier,
      builder: (context, mySite, _) {
        return AdaptiveScaffold(
          body: navItems[_selectedIndex],
          bottomNavigationBar: AdaptiveBottomNavigationBar(
            selectedIndex: _selectedIndex,
            onTap: (index) => setState(() => _selectedIndex = index),
            useNativeBottomBar: true,
            items: [
              const AdaptiveNavigationDestination(
                icon: 'house',
                selectedIcon: 'house.fill',
                label: 'Főoldal',
              ),
              const AdaptiveNavigationDestination(
                icon: 'calendar',
                selectedIcon: 'calendar',
                label: 'Naptár',
              ),
              AdaptiveNavigationDestination(
                icon: 'person.2',
                selectedIcon: 'person.2.fill',
                label: 'Wiki',
                badgeCount: mySite == null ? 1 : null,
              ),
              const AdaptiveNavigationDestination(
                icon: 'gearshape',
                selectedIcon: 'gearshape.fill',
                label: 'Beállítások',
                addSpacerAfter: true,
              ),
            ],
            bottomNavigationBar: NavigationBar(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (index) =>
                  setState(() => _selectedIndex = index),
              destinations: [
                const NavigationDestination(
                  selectedIcon: Icon(Icons.home),
                  icon: Icon(Icons.home_outlined),
                  label: 'Főoldal',
                ),
                const NavigationDestination(
                  selectedIcon: Icon(Icons.calendar_month),
                  icon: Icon(Icons.calendar_month_outlined),
                  label: 'Naptár',
                ),
                NavigationDestination(
                  selectedIcon: mySite == null
                      ? const Badge(label: Text('1'), child: Icon(Icons.groups))
                      : const Icon(Icons.groups),
                  icon: mySite == null
                      ? const Badge(
                          label: Text('1'), child: Icon(Icons.groups_outlined))
                      : const Icon(Icons.groups_outlined),
                  label: 'Wiki',
                ),
                const NavigationDestination(
                  selectedIcon: Icon(Icons.settings),
                  icon: Icon(Icons.settings_outlined),
                  label: 'Beállítások',
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
