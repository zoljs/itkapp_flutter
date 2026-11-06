import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:itk_app/ui/core/theme/app_spacing.dart';

class NavBarItem {
  const NavBarItem(
      {required this.icon, required this.label, required this.selectedIcon});
  final IconData icon;
  final IconData selectedIcon;
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

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            scheme.surface.withValues(alpha: 0.0),
            scheme.surface.withValues(alpha: 0.7),
            scheme.surface,
            scheme.surface,
          ],
          stops: const [0.0, 0.3, 0.7, 1.0],
        ),
      ),
      child: SafeArea(
        child: SizedBox(
          height: 50,
          child: Stack(
            children: [
              Positioned.fill(
                child: SlidingTabPill(
                  index: selectedIndex,
                  count: items.length,
                ),
              ),
              Row(
                children: List.generate(items.length, (index) {
                  return Expanded(
                    child: NavBarTab(
                      item: items[index],
                      selected: index == selectedIndex,
                      onTap: () {
                        if (index != selectedIndex) {
                          unawaited(HapticFeedback.selectionClick());
                        }
                        onTap(index);
                      },
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// One tab of [AppNavBar]. Selecting it morphs the outlined icon into the
/// filled one (scale + fade with a small overshoot) and fades the color and
/// label weight, instead of switching them instantly.
class NavBarTab extends StatelessWidget {
  const NavBarTab({
    super.key,
    required this.item,
    required this.selected,
    required this.onTap,
  });

  static const selectedColor = Colors.white;
  static const unselectedColor = Color(0xFF9E9E9E);
  static const duration = Duration(milliseconds: 250);

  final NavBarItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final duration = reduceMotion ? Duration.zero : NavBarTab.duration;
    final color = selected ? selectedColor : unselectedColor;

    return Semantics(
      button: true,
      selected: selected,
      label: item.label,
      // excludeSemantics also drops the GestureDetector's tap action, so the
      // node needs its own, or a screen reader cannot activate the tab.
      onTap: onTap,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            PopOnSelect(
              selected: selected,
              child: TweenAnimationBuilder<Color?>(
                tween: ColorTween(end: color),
                duration: duration,
                curve: Curves.easeOut,
                builder: (context, animatedColor, _) => AnimatedSwitcher(
                  duration: duration,
                  switchInCurve: Curves.easeOutBack,
                  switchOutCurve: Curves.easeIn,
                  transitionBuilder: (child, animation) => FadeTransition(
                    opacity: animation,
                    child: ScaleTransition(
                      scale: Tween(begin: 0.7, end: 1.0).animate(animation),
                      child: child,
                    ),
                  ),
                  child: Icon(
                    selected ? item.selectedIcon : item.icon,
                    key: ValueKey(selected),
                    color: animatedColor,
                    size: 28,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            AnimatedDefaultTextStyle(
              duration: duration,
              curve: Curves.easeOut,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              ),
              child: Text(item.label),
            ),
          ],
        ),
      ),
    );
  }
}

/// Scales its child up and back once (1 -> [peak] -> 1) when [selected]
/// turns true. Deselecting does nothing, so only the new tab pops.
class PopOnSelect extends StatefulWidget {
  const PopOnSelect({
    super.key,
    required this.selected,
    required this.child,
    this.peak = 1.15,
    this.duration = const Duration(milliseconds: 300),
  });

  final bool selected;
  final Widget child;
  final double peak;
  final Duration duration;

  @override
  State<PopOnSelect> createState() => _PopOnSelectState();
}

class _PopOnSelectState extends State<PopOnSelect>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: widget.duration);

  @override
  void didUpdateWidget(covariant PopOnSelect oldWidget) {
    super.didUpdateWidget(oldWidget);
    final becameSelected = widget.selected && !oldWidget.selected;
    if (becameSelected && !MediaQuery.disableAnimationsOf(context)) {
      unawaited(_controller.forward(from: 0));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // sin(0..pi): 0 -> 1 -> 0, so the scale goes 1 -> peak -> 1.
        final t = Curves.easeOut.transform(_controller.value);
        final scale = 1 + (widget.peak - 1) * math.sin(math.pi * t);
        return Transform.scale(scale: scale, child: child);
      },
      child: widget.child,
    );
  }
}

/// Highlight behind the selected tab. When the selection changes it moves
/// like a drop of liquid: the leading edge runs ahead to the new tab, the
/// trailing edge follows a little later, so the pill stretches and then
/// snaps back to one tab width.
class SlidingTabPill extends StatefulWidget {
  const SlidingTabPill({
    super.key,
    required this.index,
    required this.count,
    this.duration = const Duration(milliseconds: 850),
  });

  static const pillKey = ValueKey('nav-bar-pill');
  static const horizontalInset = 8.0;
  static const verticalInset = 3.0;

  final int index;
  final int count;
  final Duration duration;

  @override
  State<SlidingTabPill> createState() => _SlidingTabPillState();
}

class _SlidingTabPillState extends State<SlidingTabPill>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: widget.duration, value: 1);
  late int _from = widget.index;

  // Leading edge: fast start. Trailing edge: starts later, eases in and out.
  static const _lead = Curves.elasticOut;
  static const _trail = Interval(0.1, 1, curve: Curves.elasticOut);

  @override
  void didUpdateWidget(covariant SlidingTabPill oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.index == oldWidget.index) return;
    if (MediaQuery.disableAnimationsOf(context)) {
      _from = widget.index;
      _controller.value = 1;
      return;
    }
    // Start from the previous tab. A tap during the animation restarts the
    // move from that tab (a small jump), which is fine for a 450 ms effect.
    _from = oldWidget.index;
    unawaited(_controller.forward(from: 0));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Left and right edge of the pill, in tab units.
  (double, double) edgesAt(double t) {
    final from = _from.toDouble();
    final to = widget.index.toDouble();
    final movingRight = to >= from;
    final leftCurve = movingRight ? _trail : _lead;
    final rightCurve = movingRight ? _lead : _trail;
    final left = from + (to - from) * leftCurve.transform(t);
    final right = from + 1 + (to - from) * rightCurve.transform(t);
    return (left, right);
  }

  @override
  Widget build(BuildContext context) {
    final color = Colors.white.withValues(alpha: 0.12);

    return LayoutBuilder(
      builder: (context, constraints) {
        final tabWidth = constraints.maxWidth / widget.count;
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final (left, right) = edgesAt(_controller.value);
            return Stack(
              children: [
                Positioned(
                  key: SlidingTabPill.pillKey,
                  left: left * tabWidth + SlidingTabPill.horizontalInset,
                  width: (right - left) * tabWidth -
                      2 * SlidingTabPill.horizontalInset,
                  top: SlidingTabPill.verticalInset,
                  bottom: SlidingTabPill.verticalInset,
                  child: DecoratedBox(
                    decoration: ShapeDecoration(
                      color: color,
                      shape: const StadiumBorder(),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
