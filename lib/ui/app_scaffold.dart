import 'package:itk_app/ui/calendar/calendar_screen.dart';
import 'package:itk_app/ui/home/home_screen.dart';
import 'package:itk_app/ui/settings/settings_screen.dart';
import 'package:itk_app/ui/wiki/wiki_screen.dart';
import 'package:itk_app/data/repositories/sites_repository.dart';
import 'package:flutter/material.dart';
import 'package:itk_app/ui/core/widgets/navbar.dart';

class AppScaffold extends StatefulWidget {
  const AppScaffold({super.key});

  @override
  State<AppScaffold> createState() => _AppScaffoldState();
}

class _AppScaffoldState extends State<AppScaffold> {
  @override
  void initState() {
    super.initState();
    SitesRepository.instance.getMySite();
  }

  int _selectedIndex = 0;

  final List<Widget> navItems = [
    const HomeScreen(),
    const CalendarScreen(),
    const WikiScreen(),
    // const OnlineVideos(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
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
          // NavBarItem(
          //     icon: Icons.video_chat_outlined,
          //     label: 'Online',
          //     selectedIcon: Icons.video_chat),
          NavBarItem(
              icon: Icons.settings_outlined,
              label: 'Beállítások',
              selectedIcon: Icons.settings_rounded)
        ],
      ),
    );
  }
}
