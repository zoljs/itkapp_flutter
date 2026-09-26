import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:material_ui/material_ui.dart';

enum AdaptiveButtonVariant {
  primary,
  secondary,
  destructive,
}

class AdaptiveButton extends StatelessWidget {
  const AdaptiveButton({
    super.key,
    required this.child,
    required this.onPressed,
    this.variant = AdaptiveButtonVariant.primary,
    this.fullWidth = true,
    this.height = 52,
  });
  final Widget child;
  final VoidCallback? onPressed;
  final AdaptiveButtonVariant variant;

  final bool fullWidth;
  final double height;

  @override
  Widget build(BuildContext context) {
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;
    final button = isIOS ? _buildCupertino(context) : _buildMaterial(context);

    return SizedBox(
      height: height,
      width: fullWidth ? double.infinity : null,
      child: button,
    );
  }

  Widget _buildMaterial(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    switch (variant) {
      case AdaptiveButtonVariant.primary:
        return FilledButton(onPressed: onPressed, child: child);

      case AdaptiveButtonVariant.secondary:
        return FilledButton.tonal(onPressed: onPressed, child: child);

      case AdaptiveButtonVariant.destructive:
        return OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: scheme.error,
            side: BorderSide(color: scheme.error),
          ),
          child: child,
        );
    }
  }

  Widget _buildCupertino(BuildContext context) {
    switch (variant) {
      case AdaptiveButtonVariant.primary:
        return CupertinoButton.filled(
          color: CupertinoColors.activeBlue,
          foregroundColor: CupertinoColors.white,
          borderRadius: BorderRadius.circular(25),
          onPressed: onPressed,
          child: child,
        );
      case AdaptiveButtonVariant.secondary:
        return CupertinoButton(
          color: CupertinoColors.systemGrey5.resolveFrom(context),
          borderRadius: BorderRadius.circular(25),
          onPressed: onPressed,
          child: child,
        );
      case AdaptiveButtonVariant.destructive:
        return CupertinoButton(
          color: CupertinoColors.systemGrey5.resolveFrom(context),
          borderRadius: BorderRadius.circular(25),
          foregroundColor: CupertinoColors.destructiveRed,
          onPressed: onPressed,
          child: child,
        );
    }
  }
}
