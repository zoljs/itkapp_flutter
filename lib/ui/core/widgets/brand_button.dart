import 'package:flutter/material.dart';
import 'package:itk_app/ui/core/theme/app_radius.dart';
import 'package:itk_app/ui/core/widgets/app_pressable.dart';

class BrandButton extends StatelessWidget {
  const BrandButton({
    super.key,
    required this.onTap,
    required this.child,
    required this.backgroundColor,
    this.height = 48,
  });

  final VoidCallback? onTap;
  final Widget child;
  final Color backgroundColor;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return AppPressable(
      onTap: onTap,
      color: backgroundColor,
      shape: RoundedSuperellipseBorder(
        borderRadius: BorderRadius.circular(AppRadius.xxl),
      ),
      child: SizedBox(
        height: height,
        child: Center(child: child),
      ),
    );
  }
}
