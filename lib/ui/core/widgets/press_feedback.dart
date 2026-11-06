import 'package:flutter/material.dart';

/// Pressed look for custom buttons: the child shrinks a little and darkens.
///
/// Built on an implicit animation (ticker). flutter_animate's `.animate()`
/// starts a timer even in target mode, which stays pending in widget tests
/// that only pump once.
class PressFeedback extends StatelessWidget {
  const PressFeedback({
    super.key,
    required this.pressed,
    required this.child,
    this.pressedScale = 0.96,
    this.tint = 0.15,
  });

  static const duration = Duration(milliseconds: 100);

  final bool pressed;
  final Widget child;

  /// Scale while pressed (1 = no shrink).
  final double pressedScale;

  /// Black overlay strength while pressed (0..1).
  final double tint;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(end: pressed ? 1 : 0),
      duration: duration,
      builder: (context, t, child) => Transform.scale(
        scale: 1 - (1 - pressedScale) * t,
        child: ColorFiltered(
          colorFilter: ColorFilter.mode(
            Colors.black.withValues(alpha: tint * t),
            BlendMode.srcATop,
          ),
          child: child,
        ),
      ),
      child: child,
    );
  }
}
