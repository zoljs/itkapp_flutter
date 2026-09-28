import 'package:itk_app/ui/core/theme/app_radius.dart';
import 'package:itk_app/ui/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';

class UserSiteCard extends StatelessWidget {
  final Color color;
  final Widget child;
  final double? height;
  final void Function() onTap;

  const UserSiteCard(
      {super.key,
      required this.color,
      required this.child,
      this.height,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: const EdgeInsets.all(AppSpacing.xs),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.lerp(color, Colors.white, 0.5)!,
            color.withValues(alpha: 0.5),
          ],
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        clipBehavior: Clip.antiAlias,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color,
                Color.lerp(color, Colors.black, 0.12)!,
              ],
            ),
          ),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
