import 'package:go_router/go_router.dart';
import 'package:itk_app/data/repositories/sites_repository.dart';
import 'package:flutter/material.dart';
import 'package:itk_app/ui/core/widgets/navbar.dart';
import 'package:provider/provider.dart';

class AppScaffold extends StatefulWidget {
  const AppScaffold({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  State<AppScaffold> createState() => _AppScaffoldState();
}

class _AppScaffoldState extends State<AppScaffold> {
  @override
  void initState() {
    super.initState();
    context.read<SitesRepository>().getMySite();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: widget.navigationShell,
      bottomNavigationBar: AppNavBar(
        selectedIndex: widget.navigationShell.currentIndex,
        onTap: (index) => setState(() => widget.navigationShell.goBranch(index)),
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
