import 'package:flutter/material.dart';
import 'package:itk_app/ui/core/widgets/brand_icon_button.dart';

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
    actionsPadding: const EdgeInsets.all(8.0),
    actions: [
      TextButton(onPressed: onPressed, child: const Text("Kész")),
    ],
  );
}
