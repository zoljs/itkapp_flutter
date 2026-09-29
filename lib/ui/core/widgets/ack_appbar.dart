import 'package:flutter/material.dart';
import 'package:itk_app/ui/core/theme/app_spacing.dart';

PreferredSizeWidget buildAckAppBar({
  required ColorScheme scheme,
  required Widget title,
  required BuildContext context,
  Function()? onPressed,
}) {
  return AppBar(
    backgroundColor: Colors.transparent,
    scrolledUnderElevation: 0,
    flexibleSpace: Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            scheme.surface,
            scheme.surface,
            scheme.surface.withValues(alpha: 0.0),
          ],
          stops: const [0.0, 0.55, 1.0],
        ),
      ),
    ),
    title: title,
    actions: [
      Padding(
        padding: const EdgeInsets.all(4.0),
        child: SizedBox.square(
          dimension: 48,
          child: IconButton(
            iconSize: 28,
            style: IconButton.styleFrom(backgroundColor: Colors.transparent),
            constraints: BoxConstraints.tight(
              const Size.square(AppSpacing.minimumAndroid),
            ),
            onPressed: onPressed,
            icon: const Icon(
              Icons.check,
              color: Colors.white70,
            ),
          ),
        ),
      ),
    ],
  );
}
