import 'package:itk_app/ui/calendar/calendar_screen_test.dart';
import 'package:itk_app/ui/home/home_screen_test.dart';
import 'package:itk_app/ui/settings/settings_screen.dart';
import 'package:itk_app/ui/wiki/wiki_screen.dart';
import 'package:itk_app/data/services/sites_service.dart';
import 'package:flutter/material.dart';
import 'package:itk_app/ui/core/widgets/navbar.dart';
import 'package:itk_app/ui/online_videos/online_videos.dart';

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
    const OnlineVideos(),
  ];

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: SitesService.instance.mySiteNotifier,
      builder: (context, mySite, _) {
        return Scaffold(
          extendBody: true,
          body: navItems[_selectedIndex],
          bottomNavigationBar: AppNavBar(
            selectedIndex: _selectedIndex,
            onTap: (index) => setState(() => _selectedIndex = index),
            items: const [
              NavBarItem(
                  icon: Icons.home_outlined,
                  selectedIcon: Icons.home_rounded,
                  label: 'Főoldal'),
              NavBarItem(
                  icon: Icons.calendar_month_outlined,
                  selectedIcon: Icons.calendar_month_rounded,
                  label: 'Naptár'),
              NavBarItem(
                  icon: Icons.groups_outlined,
                  selectedIcon: Icons.groups_rounded,
                  label: 'Wiki'),
              //NavBarItem(icon: Icons.note_rounded, label: 'ZHk'),
              NavBarItem(
                  icon: Icons.settings_outlined,
                  selectedIcon: Icons.settings_rounded,
                  label: 'Beállítások'),
              NavBarItem(
                  icon: Icons.video_chat_outlined,
                  label: 'Online Tananyagok',
                  selectedIcon: Icons.video_chat_rounded)
            ],
          ),
        );
      },
    );
  }
}
