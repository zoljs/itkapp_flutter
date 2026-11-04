import 'package:flutter/material.dart';
import 'package:itk_app/domain/models/user_site.dart';
import 'package:itk_app/ui/core/theme/app_radius.dart';
import 'package:itk_app/ui/core/theme/app_spacing.dart';
import 'package:itk_app/ui/core/theme/site_colors.dart';
import 'package:itk_app/ui/core/widgets/app_spinner.dart';
import 'package:itk_app/ui/wiki/widgets/user_site_card.dart';
import 'package:skeletonizer/skeletonizer.dart';

class SiteListCard extends StatelessWidget {
  const SiteListCard({
    super.key,
    required this.site,
    required this.checking,
    required this.onTap,
  });

  final UserSite site;
  final bool checking;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return UserSiteCard(
      color: site.claimed ? site.color.color : Colors.grey,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  site.name,
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: site.tags.take(4).map((tag) {
              return Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Skeleton.ignore(
                  child: Text(
                    tag,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: Text(
                  Uri.tryParse(site.url)?.host ?? site.url,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, color: Colors.black87),
                ),
              ),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.25),
                  shape: BoxShape.circle,
                ),
                child: checking
                    ? const Padding(
                        padding: EdgeInsets.all(AppSpacing.sm),
                        child: AppSpinner(
                          color: Colors.black87,
                        ),
                      )
                    : const Skeleton.ignore(
                        child: Icon(
                          Icons.arrow_forward_rounded,
                          color: Colors.black87,
                          size: 24,
                        ),
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
