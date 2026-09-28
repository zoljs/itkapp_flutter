import 'package:flutter/material.dart';

class NavBarItem {
  const NavBarItem({required this.icon, required this.label});
  final IconData icon;
  final String label;
}

class AppNavBar extends StatelessWidget {
  const AppNavBar({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onTap,
  });

  final List<NavBarItem> items;
  final int selectedIndex;
  final ValueChanged<int> onTap;

  static const _selectedColor = Colors.white;
  static const _unselectedColor = Color(0xFF9E9E9E);

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      height: 84,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            scheme.surface.withValues(alpha: 0.0),
            scheme.surface.withValues(alpha: 0.7),
            scheme.surface.withValues(alpha: 0.9),
            scheme.surface,
          ],
          stops: const [0.0, 0.33, 0.66, 1.0],
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: List.generate(items.length, (index) {
            final item = items[index];
            final selected = index == selectedIndex;
            final color = selected ? _selectedColor : _unselectedColor;

            return Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onTap(index),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(item.icon, color: color, size: 28),
                    const SizedBox(height: 4),
                    Text(
                      item.label,
                      style: TextStyle(
                        color: color,
                        fontSize: 11,
                        fontWeight:
                            selected ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
