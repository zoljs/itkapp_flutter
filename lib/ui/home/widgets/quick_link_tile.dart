import 'package:flutter/material.dart';
import 'package:itk_app/ui/core/theme/app_radius.dart';
import 'package:itk_app/ui/core/theme/app_spacing.dart';
import 'package:itk_app/ui/home/widgets/quick_links_grid.dart';

class QuickLinkTile extends StatelessWidget {
  const QuickLinkTile({
    super.key,
    required this.onTap,
    required this.link,
    required this.scheme,
  });

  final ValueChanged<String> onTap;
  final QuickLink link;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.lg),
      onTap: () => onTap(link.url),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            link.iconAsset,
            height: 32,
            errorBuilder: (_, __, ___) => Icon(
              Icons.link_rounded,
              size: 32,
              color: scheme.primary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            link.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 12, color: scheme.onSurface),
          ),
        ],
      ),
    );
  }
}
