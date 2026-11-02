import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Platform loading spinner with a controllable color.
///
/// Use instead of `CircularProgressIndicator.adaptive()`: on iOS that one
/// is grey and disappears on colored backgrounds. Pass the foreground color
/// of the surface it sits on (e.g. `Colors.black87` on a site card).

class AppSpinner extends StatelessWidget {
  const AppSpinner({super.key, this.color});

  final Color? color;
  static const size = 20.0;

  @override
  Widget build(BuildContext context) {
    return switch (Theme.of(context).platform) {
      TargetPlatform.android => CupertinoActivityIndicator(color: color),
      _ => SizedBox.square(
          dimension: size,
          child: CircularProgressIndicator(color: color, strokeWidth: 2.5),
        ),
    };
  }
}
