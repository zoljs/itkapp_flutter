import 'package:flutter/material.dart';
import 'package:itk_app/ui/core/theme/app_spacing.dart';
import 'package:itk_app/ui/core/widgets/adaptive_sheet.dart';
import 'package:itk_app/ui/core/widgets/brand_appbar.dart';
import 'package:itk_app/ui/core/widgets/grouped_list.dart';
import 'package:itk_app/utils/semester.dart';

class SemesterPickerScreen extends StatelessWidget {
  const SemesterPickerScreen(
      {super.key, required this.selected, this.scrollController});

  final String selected;
  final ScrollController? scrollController;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final options = recentSemesters(count: 14);
    if (!options.contains(selected)) options.insert(0, selected);
    final current = currentSemester();

    return Scaffold(
      backgroundColor: sheetBackgroundColor(context),
      appBar: buildBrandAppBar(context: context, title: 'Félév'),
      body: ListView(
        controller: scrollController,
        padding: EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.lg,
          MediaQuery.paddingOf(context).bottom + AppSpacing.xxxl,
        ),
        children: [
          SettingsGroup(
            children: [
              for (final s in options)
                SettingsTile(
                  title: semesterLabel(s),
                  value: s == current ? 'aktuális' : null,
                  trailing: SizedBox(
                    width: 32,
                    child: s == selected
                        ? Icon(Icons.check_rounded, color: scheme.primary)
                        : null,
                  ),
                  onTap: () => Navigator.pop(context, s),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
