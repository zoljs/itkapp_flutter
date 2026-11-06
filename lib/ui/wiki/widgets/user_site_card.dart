import 'package:flutter/material.dart';
import 'package:itk_app/ui/core/theme/app_radius.dart';
import 'package:itk_app/ui/core/theme/app_spacing.dart';
import 'package:itk_app/ui/core/widgets/app_pressable.dart';

class UserSiteCard extends StatelessWidget {
  const UserSiteCard({
    super.key,
    required this.color,
    required this.child,
    this.height,
    this.onTap,
  });

  final Color color;
  final Widget child;
  final double? height;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return AppPressable(
      onTap: onTap,
      color: color,
      shape: RoundedSuperellipseBorder(
        borderRadius: BorderRadius.circular(AppRadius.xxl),
      ),
      pressedScale: 0.95,
      child: SizedBox(
        height: height,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
          child: child,
        ),
      ),
    );
  }
}
