import 'package:flutter/material.dart';

class FadingLogo extends StatelessWidget {
  const FadingLogo(
      {super.key, required this.showWhenCollapsed, required this.height});

  final bool showWhenCollapsed;
  final double height;

  @override
  Widget build(BuildContext context) {
    final settings =
        context.dependOnInheritedWidgetOfExactType<FlexibleSpaceBarSettings>();

    var expanded = 1.0;
    if (settings != null) {
      final delta = settings.maxExtent - settings.minExtent;
      expanded = ((settings.currentExtent - settings.minExtent) / delta)
          .clamp(0.0, 1.0);
    }
    final opacity = showWhenCollapsed
        ? 1.0 - expanded
        : ((expanded - 0.6) / 0.4).clamp(0.0, 1.0);

    return Opacity(
      opacity: opacity,
      child: Image.asset('assets/icons/itkapp-small.png', height: height),
    );
  }
}
