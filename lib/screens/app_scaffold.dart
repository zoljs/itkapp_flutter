import 'package:itk_app/screens/home_screen_test.dart';
import 'package:itk_app/screens/settings_screen.dart';
import 'package:itk_app/screens/wiki_screen.dart';
import 'package:itk_app/services/calendar_service.dart';
import 'package:itk_app/services/sites_service.dart';
import 'package:material_ui/material_ui.dart';

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

    CalendarService.instance.getCalendar('perpa4');
  }

  int _selectedIndex = 0;
  final List<Widget> navItems = [
    const HomeScreenTest(),
    const WikiScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: navItems[_selectedIndex],
      //bottomNavigationBar: _buildBottomNavigationBar(),
      bottomNavigationBar: NavigationBar(
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
            label: 'Főoldal',
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
      ),
    );
  }
}
