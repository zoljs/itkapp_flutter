import 'package:flutter/material.dart';
import 'package:itk_app/ui/core/theme/app_spacing.dart';
import 'package:itk_app/ui/core/theme/app_themes.dart';
import 'package:itk_app/ui/core/widgets/adaptive_sheet.dart';
import 'package:itk_app/ui/core/widgets/brand_icon_button.dart';

PreferredSizeWidget buildBrandAppBar({
  required BuildContext context,
  required String title,
  bool closesSheet = false,
  String actionLabel = 'Mentés',
  IconData actionIcon = Icons.check_rounded,
  VoidCallback? onAction,
}) {
  final scheme = Theme.of(context).colorScheme;
  final theme = Theme.of(context);

  return PreferredSize(
    preferredSize: const Size.fromHeight(AppSpacing.toolbarHeight),
    child: SafeArea(
      child: ColoredBox(
        color: Colors.transparent,
        child: Padding(
          padding:
              const EdgeInsets.only(left: AppSpacing.sm, right: AppSpacing.sm),
          child: NavigationToolbar(
            centerMiddle: true,
            middleSpacing: AppSpacing.md,
            leading: closesSheet
                ? Center(
                    widthFactor: 1,
                    child: BrandIconButton(
                      icon: Icons.close,
                      semanticLabel: "Mégse",
                      backgroundColor: scheme.surfaceBright,
                      iconColor: scheme.onSurface,
                      onPressed: () => closeSheet(context),
                    ),
                  )
                : Center(
                    widthFactor: 1,
                    child: BrandIconButton(
                      icon: Icons.arrow_back_rounded,
                      semanticLabel: "Vissza",
                      backgroundColor: scheme.surfaceBright,
                      iconColor: scheme.onSurface,
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
            middle: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleMedium,
            ),
            trailing: onAction == null
                ? null
                : BrandIconButton(
                    onPressed: onAction,
                    icon: actionIcon,
                    backgroundColor: itkPrimary,
                    iconColor: itkDark,
                    semanticLabel: 'Mentés',
                  ),
          ),
        ),
      ),
    ),
  );
}
