import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:itk_app/ui/core/widgets/navbar.dart';

class AppScaffold extends StatelessWidget {
  const AppScaffold({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: navigationShell,
      bottomNavigationBar: AppNavBar(
        selectedIndex: navigationShell.currentIndex,
        onTap: (index) => navigationShell.goBranch(index),
        items: const [
          NavBarItem(icon: Icons.home_outlined, selectedIcon: Icons.home_rounded, label: 'Főoldal'),
          NavBarItem(icon: Icons.calendar_month_outlined, selectedIcon: Icons.calendar_month_rounded, label: 'Naptár'),
          NavBarItem(icon: Icons.groups_outlined, selectedIcon: Icons.groups_rounded, label: 'Wiki'),
          NavBarItem(icon: Icons.settings_outlined, label: 'Beállítások', selectedIcon: Icons.settings_rounded)
        ],
      ),
    );
  }
}
