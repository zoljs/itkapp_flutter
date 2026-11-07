import 'package:flutter/material.dart';

/// Pressed look for custom buttons: the child shrinks a little and shows
/// an [InkWell] ripple.
///
/// Built on an implicit animation (ticker). flutter_animate's `.animate()`
/// starts a timer even in target mode, which stays pending in widget tests
/// that only pump once.
class AppPressable extends StatefulWidget {
  const AppPressable({
    super.key,
    required this.child,
    this.onTap,
    this.semanticLabel,
    this.color,
    this.shape,
    this.pressedScale = 0.96,
  });

  static const disabledOpacity = 0.4;
  static const duration = Duration(milliseconds: 250);

  final Widget child;
  final VoidCallback? onTap;
  final String? semanticLabel;
  final Color? color;
  final ShapeBorder? shape;

  /// Scale while pressed (1 = no shrink).
  final double pressedScale;

  @override
  State<AppPressable> createState() => _AppPressableState();
}

class _AppPressableState extends State<AppPressable> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    // Wrapped in [AnimatedScale], which shows the press.
    return AnimatedScale(
      scale: _pressed ? widget.pressedScale : 1,
      duration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : AppPressable.duration,
      curve: Curves.easeOutBack,

      // [InkWell] requires a [Material] ancestor to draw a ripple on.
      child: Material(
        color: widget.color ?? Colors.transparent,
        shape: widget.shape,
        clipBehavior: Clip.antiAlias,

        // [InkWell] presents a light ripple which implies the press. It's my
        // decision to keep the light ripple as opposed to a dark one, as
        // darker shades mean disabled state.
        child: InkWell(
          onTap: widget.onTap,
          onHighlightChanged: (value) => setState(() => _pressed = value),
          customBorder: widget.shape,

          // Important to provide semantics for screen readers.
          // Inside the [Material], not around it: skeletonizer paints a
          // `button: true` node as one solid bone, which would hide the
          // card color and its text in loading skeletons.
          child: Semantics(
            button: true,
            enabled: widget.onTap != null,
            label: widget.semanticLabel,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
