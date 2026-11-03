import 'package:flutter/material.dart';
import 'package:itk_app/ui/core/widgets/grouped_list.dart';
import 'package:itk_app/ui/core/widgets/swipe_to_delete.dart';
import 'package:skeletonizer/skeletonizer.dart';

class MySiteTagsGroup extends StatelessWidget {
  const MySiteTagsGroup({
    super.key,
    required this.tags,
    required this.loading,
    required this.onAdd,
    required this.onDelete,
  });

  final List<String> tags;
  final bool loading;
  final VoidCallback onAdd;
  final ValueChanged<String> onDelete;

  static const _skeletonTags = ['Címke 1', 'Címke 2', 'Címke 3'];

  @override
  Widget build(BuildContext context) {
    final shownTags = loading ? _skeletonTags : tags;

    return SettingsGroup(
      header: 'Címkék',
      footer: 'A címkék alapján a kereső is listázza az oldalakat.'
          '\nBalra húzva törölheted a címkét.',
      children: [
        SettingsTile(
          title: 'Új címke hozzáadása',
          onTap: onAdd,
        ),
        ...shownTags.map((tag) {
          return Skeletonizer(
            enabled: loading,
            child: SwipeToDelete(
              id: tag,
              confirmTitle: 'Címke törlése',
              confirmMessage: 'Biztosan törlöd a "$tag" címkét?',
              onDelete: () => onDelete(tag),
              child: SettingsTile(
                title: tag,
              ),
            ),
          );
        }),
      ],
    );
  }
}
