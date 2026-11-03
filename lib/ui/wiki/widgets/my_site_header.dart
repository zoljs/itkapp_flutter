import 'package:flutter/material.dart';
import 'package:itk_app/domain/models/site_color.dart';
import 'package:itk_app/ui/core/theme/site_colors.dart';
import 'package:itk_app/ui/core/widgets/grouped_list.dart';
import 'package:itk_app/ui/core/widgets/user_avatar.dart';

class MySiteHeader extends StatelessWidget {
  const MySiteHeader({
    super.key,
    required this.login,
    required this.siteColor,
  });

  final String? login;
  final SiteColor siteColor;

  static const heroTag = 'wiki-mysite-avatar';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Hero(
          tag: heroTag,
          child: UserAvatar(
            login: login,
            color: Color.alphaBlend(
              Colors.white.withValues(alpha: 0.3),
              siteColor.color,
            ),
          ),
        ),
        SettingsGroup(
          header: 'Adatok',
          footer: 'Az oldal neve és az URL a bejelentkezett fiókodhoz van rögzítve, nem módosítható.',
          children: [
            SettingsTile(
              title: 'Név és URL',
              value: login ?? '',
            ),
          ],
        ),
      ],
    );
  }
}
