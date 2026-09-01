import 'package:itk_app/models/user_site.dart';
import 'package:itk_app/theme/app_spacing.dart';
import 'package:itk_app/theme/app_theme_colors.dart';
import 'package:itk_app/widgets/user_site_card.dart';
import 'package:material_ui/material_ui.dart';

class MySiteCard extends StatelessWidget {
  const MySiteCard({super.key, required this.mySite, required this.openMySite});

  final UserSite? mySite;
  final void Function() openMySite;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final schemeExtension = Theme.of(context).extension<AppThemeColors>()!;

    // No own site yet
    if (mySite == null) {
      return SizedBox(
        height: 80,
        child: Material(
          color: scheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(24.5),
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
      color: schemeExtension.itkPrimary,
      height: 80,
      onTap: openMySite,
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: Colors.white.withValues(alpha: 0.25),
            child: Text(
              mySite!.name.isNotEmpty ? mySite!.name[0].toUpperCase() : '?',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: Theme.of(context).extension<AppThemeColors>()!.textDark,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xs, vertical: AppSpacing.xxs),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Saját oldalam',
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.4,
                      color: Theme.of(context)
                          .extension<AppThemeColors>()!
                          .textDark,
                    ),
                  ),
                ),
                Text(
                  mySite!.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color:
                        Theme.of(context).extension<AppThemeColors>()!.textDark,
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
            icon: Icon(Icons.edit_rounded,
                color: Theme.of(context).extension<AppThemeColors>()!.textDark),
          ),
        ],
      ),
    );
  }
}
