import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:itk_app/ui/core/theme/app_spacing.dart';
import 'package:itk_app/ui/core/widgets/confirm_dialog.dart';

class SwipeToDelete extends StatefulWidget {
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
  State<SwipeToDelete> createState() => _SwipeToDeleteState();
}

class _SwipeToDeleteState extends State<SwipeToDelete> {
  bool _reached = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Dismissible(
      key: ValueKey(widget.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: scheme.error,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: AnimatedScale(
          curve: Curves.bounceOut,
          scale: _reached ? 2 : 1.0,
          duration: const Duration(milliseconds: 400),
          child: Icon(
            widget.icon,
            color: scheme.onError,
          ),
        ),
      ),
      confirmDismiss: (_) async =>
          await showConfirmDialog(
            context,
            title: widget.confirmTitle,
            message: widget.confirmMessage,
            confirmLabel: widget.confirmLabel,
            isDestructive: true,
          ) ==
          true,
      onDismissed: (_) => widget.onDelete(),
      onUpdate: (details) async {
        if (details.reached != details.previousReached) {
          setState(() => _reached = details.reached);
          await HapticFeedback.mediumImpact();
        }
      },
      child: widget.child,
    );
  }
}
