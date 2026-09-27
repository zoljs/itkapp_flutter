import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:itk_app/theme/app_radius.dart';

Widget buildDestructiveButton(
  BuildContext context,
  IconData? androidIcon, {
  required String label,
  required VoidCallback onPressed,
}) {
  final isIOS = Theme.of(context).platform == TargetPlatform.iOS;
  final scheme = Theme.of(context).colorScheme;

  if (isIOS) {
    return CupertinoButton(
      color: CupertinoColors.systemGrey5.resolveFrom(context),
      padding: EdgeInsets.zero,
      borderRadius: BorderRadius.circular(AppRadius.xxl),
      minimumSize: const Size.square(48),
      onPressed: onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label,
              style: const TextStyle(color: CupertinoColors.destructiveRed)),
        ],
      ),
    );
  }

  return SizedBox(
    width: double.infinity,
    height: 48,
    child: FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: scheme.errorContainer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xxl),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (androidIcon != null) ...[
            Icon(androidIcon, size: 18, color: scheme.error),
            const SizedBox(width: 6),
          ],
          Text(label, style: TextStyle(color: scheme.error)),
        ],
      ),
    ),
  );
}
