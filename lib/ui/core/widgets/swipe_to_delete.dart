import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:itk_app/ui/core/theme/app_radius.dart';
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
  double _progress = 0.0;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Dismissible(
      key: ValueKey(widget.id),
      direction: DismissDirection.endToStart,
      background: LayoutBuilder(builder: (context, constraints) {
        double width = constraints.maxWidth;

        return Container(
          color: Theme.of(context).scaffoldBackgroundColor,
          margin: EdgeInsets.only(left: width - (width * _progress)),
          child: Container(
            decoration: ShapeDecoration(
              color: scheme.error,
              shape: RoundedSuperellipseBorder(borderRadius: BorderRadius.circular(AppRadius.xxl)),
            ),
            margin: const EdgeInsets.only(left: AppSpacing.xs),
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: AnimatedScale(
              curve: Curves.bounceOut,
              scale: _reached ? 1.75 : 1.0,
              duration: const Duration(milliseconds: 400),
              child: Icon(
                widget.icon,
                color: scheme.onError,
              ),
            ),
          ),
        );
      }),
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
        setState(() {
          _progress = details.progress;
          if (details.reached != details.previousReached) _reached = details.reached;
        });
        if (details.reached != details.previousReached) await HapticFeedback.mediumImpact();
      },
      child: widget.child,
    );
  }
}
