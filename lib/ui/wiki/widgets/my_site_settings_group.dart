import 'package:flutter/material.dart';
import 'package:itk_app/ui/core/widgets/grouped_list.dart';
import 'package:skeletonizer/skeletonizer.dart';

class MySiteSettingsGroup extends StatelessWidget {
  const MySiteSettingsGroup({
    super.key,
    required this.loading,
    required this.isPublic,
    required this.onPublicChanged,
    required this.onOpenFileSetup,
  });

  final bool loading;
  final bool isPublic;
  final ValueChanged<bool> onPublicChanged;
  final VoidCallback onOpenFileSetup;

  @override
  Widget build(BuildContext context) {
    return SettingsGroup(
      header: 'Beállítások',
      footer: 'A fájlkezelővel az oldalad fájljai az alkalmazásban is böngészhetők.',
      children: [
        Skeletonizer(
          enabled: loading,
          child: SettingsTile(
            title: 'Oldal publikussá tétele',
            trailing: Switch.adaptive(
              value: isPublic,
              onChanged: onPublicChanged,
            ),
            onTap: () => onPublicChanged(!isPublic),
          ),
        ),
        SettingsTile(
          title: 'Fájlkezelő beállítása',
          onTap: onOpenFileSetup,
        ),
      ],
    );
  }
}
