import 'package:itk_app/domain/models/user_site.dart';
import 'package:itk_app/ui/core/theme/app_spacing.dart';
import 'package:itk_app/ui/core/theme/site_colors.dart';
import 'package:itk_app/ui/core/widgets/user_avatar.dart';
import 'package:itk_app/ui/wiki/widgets/my_site_header.dart';
import 'package:itk_app/ui/wiki/widgets/user_site_card.dart';
import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

class MySiteCard extends StatelessWidget {
  const MySiteCard(
      {super.key,
      required this.mySite,
      required this.onOpen,
      required this.onEdit});

  final UserSite? mySite;
  final ValueChanged<UserSite> onOpen;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    // No own site yet
    if (mySite == null) {
      return UserSiteCard(
        color: scheme.surfaceContainerHigh,
        onTap: onEdit,
        height: 80,
        child: Row(
          children: [
            Icon(Icons.add_circle_outline_rounded, color: scheme.primary),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Még nincs saját wiki-oldalad, hozz létre egyet!',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            Skeleton.ignore(
              child: Icon(Icons.chevron_right_rounded,
                  color: scheme.onSurfaceVariant),
            ),
          ],
        ),
      );
    }

    // Own site
    return UserSiteCard(
      color: mySite!.color.color,
      height: AppSpacing.mySiteCardHeight,
      onTap: () => onOpen(mySite!),
      child: Row(
        children: [
          Hero(
            tag: MySiteHeader.heroTag,
            child: UserAvatar(
              radius: 24,
              fontSize: 24,
              login: mySite!.login,
              color: Color.alphaBlend(
                Colors.white.withValues(alpha: 0.3),
                mySite!.color.color,
              ),
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Saját oldalam",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: onEdit,
            tooltip: 'Szerkesztés',
            icon: const Icon(Icons.edit_rounded, color: Colors.black87),
          ),
        ],
      ),
    );
  }
}
