import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:itk_app/ui/core/theme/app_spacing.dart';
import 'package:itk_app/ui/core/widgets/confirm_dialog.dart';

class SwipeToDelete extends StatelessWidget {
  const SwipeToDelete({
    super.key,
    required this.id,
    required this.confirmTitle,
    required this.confirmMessage,
    this.confirmLabel = 'Törlés',
    this.icon = Icons.delete_rounded,
    required this.onDelete,
    required this.child,
  });

  final Object id;
  final IconData icon;
  final String confirmTitle;
  final String confirmMessage;
  final String confirmLabel;
  final VoidCallback onDelete;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Dismissible(
      key: ValueKey(id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: scheme.error,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: Icon(icon, color: scheme.onError),
      ),
      confirmDismiss: (_) async =>
          await showConfirmDialog(
            context,
            title: confirmTitle,
            message: confirmMessage,
            confirmLabel: confirmLabel,
            isDestructive: true,
          ) ==
          true,
      onDismissed: (_) => onDelete(),
      onUpdate: (details) async {
        if (details.reached != details.previousReached) {
          await HapticFeedback.mediumImpact();
        }
      },
      child: child,
    );
  }
}
