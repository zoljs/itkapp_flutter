import 'package:flutter/material.dart';

/// Text whose changed characters roll like an odometer: the old character
/// leaves in one direction and the new one comes in from the other.
/// Unchanged characters stay still.
///
/// [forward] sets the direction: `true` rolls up (new comes from below, as
/// when moving to a later date), `false` rolls down.
class RollingText extends StatelessWidget {
  const RollingText(
    this.text, {
    super.key,
    required this.forward,
    this.style,
    this.duration = const Duration(milliseconds: 300),
  });

  final String text;
  final bool forward;
  final TextStyle? style;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) {
      return Text(text, style: style, maxLines: 1);
    }

    final direction = forward ? 1.0 : -1.0;
    final chars = text.characters.toList();

    // Screen readers read the whole text once, not letter by letter.
    return Semantics(
      label: text,
      excludeSemantics: true,
      // Long ranges ("okt. 30. - nov. 1.") shrink instead of overflowing.
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final char in chars)
              ClipRect(
                child: AnimatedSwitcher(
                  duration: duration,
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  transitionBuilder: (child, animation) {
                    // The switcher runs the outgoing child's animation in
                    // reverse (1 -> 0), so it needs the opposite start
                    // offset to leave on the other side.
                    final entering = child.key == ValueKey(char);
                    final from = Offset(0, entering ? direction : -direction);
                    return SlideTransition(
                      position: Tween(begin: from, end: Offset.zero)
                          .animate(animation),
                      child: child,
                    );
                  },
                  child: Text(char, key: ValueKey(char), style: style),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
