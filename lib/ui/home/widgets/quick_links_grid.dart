import 'package:flutter/material.dart';
import 'package:itk_app/ui/core/theme/app_spacing.dart';
import 'package:itk_app/ui/home/widgets/quick_link_tile.dart';

List<QuickLink> _quickLinks = [
  const QuickLink('Neptun', 'https://neptun3.ppke.hu/hallgato_uj/login', 'assets/icons/neptun.png'),
  const QuickLink('ITK Space', 'https://space.itk.ppke.hu', 'assets/icons/itk-small.png'),
  const QuickLink('TO', '', 'assets/icons/sharepoint.png'),
  const QuickLink('Oktatók', '', 'assets/icons/ppke.png'),
];

class QuickLink {
  const QuickLink(this.label, this.url, this.iconAsset);

  final String label;
  final String url;
  final String iconAsset;
}

class QuickLinksGrid extends StatelessWidget {
  const QuickLinksGrid({super.key, required this.onTap});

  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppSpacing.sm),
      children: [
        for (final link in _quickLinks) QuickLinkTile(onTap: onTap, link: link, scheme: scheme),
      ],
    );
  }
}
