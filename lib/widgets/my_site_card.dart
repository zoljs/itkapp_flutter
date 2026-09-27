import 'package:itk_app/models/user_site.dart';
import 'package:itk_app/theme/app_radius.dart';
import 'package:itk_app/theme/app_spacing.dart';
import 'package:itk_app/theme/app_themes.dart';
import 'package:itk_app/widgets/user_site_card.dart';
import 'package:flutter/material.dart';

class MySiteCard extends StatelessWidget {
  const MySiteCard({super.key, required this.mySite, required this.openMySite});

  final UserSite? mySite;
  final void Function() openMySite;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    // No own site yet
    if (mySite == null) {
      return SizedBox(
        height: 80,
        child: Material(
          color: scheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(AppRadius.xxl),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: openMySite,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
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
                  Icon(Icons.chevron_right_rounded,
                      color: scheme.onSurfaceVariant),
                ],
              ),
            ),
          ),
        ),
      );
    }

    // Own site
    return UserSiteCard(
      color: itkPrimary,
      height: 80,
      onTap: openMySite,
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: Colors.white.withValues(alpha: 0.25),
            child: Text(
              mySite!.name.isNotEmpty ? mySite!.name[0].toUpperCase() : '?',
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                color: Colors.black87,
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
            onPressed: openMySite,
            iconSize: 22,
            padding: EdgeInsets.zero,
            icon: const Icon(Icons.edit_rounded, color: Colors.black87),
          ),
        ],
      ),
    );
  }
}
