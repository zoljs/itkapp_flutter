import 'package:itk_app/screens/home_screen_test.dart';
import 'package:itk_app/screens/settings_screen.dart';
import 'package:itk_app/screens/wiki_screen.dart';
import 'package:itk_app/theme/app_spacing.dart';
import 'package:material_ui/material_ui.dart';

class AppScaffold extends StatefulWidget {
  const AppScaffold({super.key});

  @override
  State<AppScaffold> createState() => _AppScaffoldState();
}

class _AppScaffoldState extends State<AppScaffold> {
  int _selectedIndex = 0;
  final List<Widget> navItems = [
    const HomeScreenTest(),
    const HomeScreenTest(),
    const WikiScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: navItems[_selectedIndex],
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  double get _pillAlignmentX {
    return (_selectedIndex / (navItems.length - 1)) * 2 - 1;
  }

  Widget _buildBottomNavigationBar() {
    return SafeArea(
      maintainBottomViewPadding: true,
      child: Container(
        color: Colors.transparent,
        height: 100,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
          child: Material(
            color: Theme.of(context).colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(50),
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                // Size of an individual item
                final itemWidth = constraints.maxWidth / navItems.length;

                return Stack(
                  children: [
                    AnimatedAlign(
                      alignment: Alignment(_pillAlignmentX, 0),
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOutCubicEmphasized,
                      child: Container(
                        width: itemWidth,
                        height: 100,
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .secondary
                                .withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(50),
                          ),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        _buildNavItem(
                            Icons.golf_course, Icons.golf_course, 0, 'ITK'),
                        _buildNavItem(Icons.calendar_month_outlined,
                            Icons.calendar_month, 1, 'Naptár'),
                        _buildNavItem(Icons.library_books_outlined,
                            Icons.library_books, 2, 'Wiki'),
                        _buildNavItem(Icons.settings_outlined, Icons.settings,
                            3, 'Beállítások'),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
      IconData outlineIcon, IconData filledIcon, int index, String name) {
    final selected = _selectedIndex == index;

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: InkWell(
          onTap: () => setState(() => _selectedIndex = index),
          borderRadius: BorderRadius.circular(50),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                transitionBuilder: (child, animation) => ScaleTransition(
                  scale: animation,
                  child: FadeTransition(opacity: animation, child: child),
                ),
                child: Icon(
                  selected ? filledIcon : outlineIcon,
                  key: ValueKey(selected),
                  color: selected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                name,
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
