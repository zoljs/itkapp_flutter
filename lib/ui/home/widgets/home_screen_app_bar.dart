import 'package:flutter/material.dart';

class HomeScreenAppBar extends StatelessWidget {
  const HomeScreenAppBar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SliverAppBar(
      stretch: true,
      stretchTriggerOffset: 100.0,
      pinned: true,
      expandedHeight: 150,
      collapsedHeight: 60,
      scrolledUnderElevation: 0,
      backgroundColor: scheme.surface,
      title: const FadingLogo(showWhenCollapsed: true, height: 30),
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.pin,
        background: Container(
          color: scheme.primaryContainer,
          alignment: Alignment.center,
          child: const FadingLogo(showWhenCollapsed: false, height: 45),
        ),
      ),
    );
  }
}

class FadingLogo extends StatelessWidget {
  const FadingLogo({super.key, required this.showWhenCollapsed, required this.height});

  final bool showWhenCollapsed;
  final double height;

  @override
  Widget build(BuildContext context) {
    final settings = context.dependOnInheritedWidgetOfExactType<FlexibleSpaceBarSettings>();

    var expanded = 1.0;
    if (settings != null) {
      final delta = settings.maxExtent - settings.minExtent;
      expanded = ((settings.currentExtent - settings.minExtent) / delta).clamp(0.0, 1.0);
    }
    final opacity = showWhenCollapsed ? 1.0 - expanded : ((expanded - 0.6) / 0.4).clamp(0.0, 1.0);

    return Opacity(
      opacity: opacity,
      child: Image.asset('assets/icons/itkapp-small.png', height: height),
    );
  }
}
