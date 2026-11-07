import 'package:flutter/material.dart';
import 'package:itk_app/ui/core/theme/app_radius.dart';
import 'package:itk_app/ui/core/theme/app_spacing.dart';
import 'package:itk_app/ui/core/theme/app_themes.dart';
import 'package:itk_app/ui/core/widgets/app_pressable.dart';
import 'package:itk_app/ui/core/widgets/app_spinner.dart';

class BrandButton extends StatelessWidget {
  const BrandButton({
    super.key,
    required this.onTap,
    required this.child,
    this.backgroundColor = itkPrimary,
    this.foregroundColor = itkDark,
    this.height = AppSpacing.buttonHeight,
    this.loading = false,
  });

  final VoidCallback? onTap;
  final Widget child;
  final Color backgroundColor;
  final Color foregroundColor;
  final double height;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return AppPressable(
      onTap: loading ? null : onTap,
      color: backgroundColor,
      shape: RoundedSuperellipseBorder(
        borderRadius: BorderRadius.circular(AppRadius.xxl),
      ),
      child: SizedBox(
        height: height,
        child: Center(
          child: loading
              ? AppSpinner(color: foregroundColor)
              : IconTheme.merge(
                  data: IconThemeData(
                    color: foregroundColor,
                  ),
                  child: DefaultTextStyle.merge(
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: foregroundColor,
                    ),
                    child: child,
                  ),
                ),
        ),
      ),
    );
  }
}
