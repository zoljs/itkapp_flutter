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
    return Container(
      height: height,
      // drop shadow provides depth
      decoration: BoxDecoration(
        color: color, // flat background color following HIG deference principle
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: [
          BoxShadow(
            color: color.withValues(
                alpha: 0.25), // tinted shadow based on the card's primary color
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadius.lg),
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
