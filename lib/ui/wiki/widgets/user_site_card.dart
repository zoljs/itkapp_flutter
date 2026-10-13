import 'package:itk_app/ui/core/theme/app_radius.dart';
import 'package:itk_app/ui/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';

class UserSiteCard extends StatelessWidget {
  final Color color;
  final Widget child;
  final double? height;
  final VoidCallback? onTap;

  const UserSiteCard({
    super.key,
    required this.color,
    required this.child,
    this.height,
    this.onTap,
  });

  // redesigned to somewhat follow HIG
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Material(
        color: color,
        shape: RoundedSuperellipseBorder(
          borderRadius: BorderRadius.circular(AppRadius.xxl),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          highlightColor: Colors.white38,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
            child: child,
          ),
        ),
      ),
    );
  }
}
