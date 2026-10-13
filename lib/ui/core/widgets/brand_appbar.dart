import 'package:flutter/material.dart';
import 'package:itk_app/ui/core/theme/app_spacing.dart';
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
            leading: buildBrandLeading(context, closesSheet: closesSheet),
            middle: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleMedium,
            ),
            // comes in handy when displaying the button conditionally
            trailing: onAction == null
                ? null
                : buildBrandAction(
                    onAction: onAction,
                    label: 'Mentés',
                    actionIcon: actionIcon),
          ),
        ),
      ),
    ),
  );
}

Widget buildBrandAction({
  required VoidCallback onAction,
  required String label,
  required IconData actionIcon,
}) {
  return Center(
    widthFactor: 1,
    child: BrandIconButton(
      onPressed: onAction,
      icon: actionIcon,
      semanticLabel: label,
    ),
  );
}

Widget buildBrandLeading(
  BuildContext context, {
  bool closesSheet = false,
}) {
  final scheme = Theme.of(context).colorScheme;

  return Center(
    widthFactor: 1,
    child: BrandIconButton(
      icon: closesSheet ? Icons.close : Icons.arrow_back_rounded,
      semanticLabel: closesSheet ? "Mégse" : "Vissza",
      backgroundColor: scheme.surfaceContainerHigh,
      iconColor: scheme.onSurface,
      onPressed: closesSheet
          ? () => closeSheet(context)
          : () => Navigator.pop(context),
    ),
  );
}

Widget buildBrandFab({
  required IconData icon,
  required VoidCallback onPressed,
  required String semanticLabel,
}) {
  return BrandIconButton(
    icon: icon,
    semanticLabel: semanticLabel,
    size: 56,
    elevated: true,
    onPressed: onPressed,
  );
}
