import 'package:flutter/material.dart';
import 'package:itk_app/ui/core/theme/app_spacing.dart';

class BrandIconButton extends StatelessWidget {
  const BrandIconButton({super.key, this.onPressed, required this.icon});

  final VoidCallback? onPressed;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 44,
      child: IconButton(
        iconSize: 28,
        style: IconButton.styleFrom(backgroundColor: Colors.transparent),
        constraints: BoxConstraints.tight(
          const Size.square(AppSpacing.minimumAndroid),
        ),
        onPressed: onPressed,
        icon: Icon(
          icon,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }
}
