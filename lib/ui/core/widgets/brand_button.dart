import 'package:flutter/material.dart';
import 'package:itk_app/ui/core/theme/app_radius.dart';
import 'package:itk_app/ui/core/theme/app_spacing.dart';
import 'package:itk_app/ui/core/theme/app_themes.dart';
import 'package:itk_app/ui/core/widgets/app_pressable.dart';

class BrandButton extends StatelessWidget {
  const BrandButton({
    super.key,
    required this.onTap,
    required this.child,
    this.backgroundColor = itkPrimary,
    this.foregroundColor = itkDark,
    this.height = AppSpacing.buttonHeight,
  });

  final VoidCallback? onTap;
  final Widget child;
  final Color backgroundColor;
  final Color foregroundColor;
  final double height;

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
        child: IconTheme.merge(
          data: IconThemeData(
            color: foregroundColor,
          ),
          child: DefaultTextStyle.merge(
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: foregroundColor,
            ),
            child: Center(child: child),
          ),
        ),
      ),
    );
  }
}
