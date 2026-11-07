import 'package:flutter/material.dart';
import 'package:itk_app/ui/core/theme/app_spacing.dart';
import 'package:itk_app/ui/core/theme/app_themes.dart';
import 'package:itk_app/ui/core/widgets/app_pressable.dart';

class BrandIconButton extends StatelessWidget {
  const BrandIconButton({
    super.key,
    required this.icon,
    required this.semanticLabel,
    this.onPressed,
    this.backgroundColor = itkPrimary,
    this.iconColor = itkDark,
    this.size = AppSpacing.minimumAndroid,
    this.elevated = false,
  });

  final VoidCallback? onPressed;
  final String semanticLabel;
  final IconData icon;
  final Color? backgroundColor;
  final Color? iconColor;
  final double size;
  final bool elevated;

  @override
  Widget build(BuildContext context) {
    final background = backgroundColor;

    return AnimatedOpacity(
      opacity: onPressed != null ? 1 : AppPressable.disabledOpacity,
      duration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : AppPressable.duration,
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: elevated && background != null
              ? [
                  BoxShadow(
                    color: background.withValues(alpha: 0.2),
                    blurRadius: AppSpacing.md,
                    offset: const Offset(AppSpacing.xs, AppSpacing.xs),
                  ),
                ]
              : null,
        ),
        child: AppPressable(
          onTap: onPressed,
          semanticLabel: semanticLabel,
          color: background,
          shape: const CircleBorder(),
          pressedScale: 0.9,
          child: SizedBox.square(
            dimension: size,
            child: Icon(
              icon,
              size: size * 0.5,
              color: iconColor ?? Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}
