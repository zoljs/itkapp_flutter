import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:itk_app/ui/core/theme/app_spacing.dart';

class StateMessage extends StatelessWidget {
  const StateMessage({
    super.key,
    required this.icon,
    required this.message,
    this.onRetry,
  });

  final IconData icon;
  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isError = onRetry != null;

    Widget iconWidget = Icon(icon, size: 48, color: scheme.outline);
    if (isError && !MediaQuery.disableAnimationsOf(context)) {
      // Two small sideways nods that fade out. Built on an implicit
      // animation (ticker), not flutter_animate, whose start timer stays
      // pending in widget tests that only pump once.
      iconWidget = TweenAnimationBuilder<double>(
        key: ValueKey(icon),
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 400),
        builder: (context, t, child) => Transform.translate(
          offset: Offset(math.sin(t * 4 * math.pi) * 4 * (1 - t), 0),
          child: child,
        ),
        child: iconWidget,
      );
    }

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          iconWidget,
          const SizedBox(height: AppSpacing.md),
          Text(message, textAlign: TextAlign.center),
          if (onRetry != null)
            TextButton(onPressed: onRetry, child: const Text('Újra')),
        ],
      ),
    );
  }
}
