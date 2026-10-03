import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Future<bool?> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
  String cancelLabel = 'Mégse',
  bool isDestructive = false,
}) {
  final scheme = Theme.of(context).colorScheme;
  final isIOS = Theme.of(context).platform == TargetPlatform.iOS;

  return showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog.adaptive(
      title: Text(title),
      content: Text(message),
      actions: isIOS
          ? [
              CupertinoDialogAction(
                onPressed: () => Navigator.pop(context, false),
                child: Text(cancelLabel),
              ),
              CupertinoDialogAction(
                isDestructiveAction: isDestructive,
                isDefaultAction: !isDestructive,
                onPressed: () => Navigator.pop(context, true),
                child: Text(confirmLabel),
              ),
            ]
          : [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(cancelLabel),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                style: isDestructive
                    ? FilledButton.styleFrom(
                        backgroundColor: scheme.errorContainer,
                        foregroundColor: scheme.error)
                    : null,
                child: Text(
                  confirmLabel,
                ),
              ),
            ],
    ),
  );
}
