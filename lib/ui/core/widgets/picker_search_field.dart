import 'package:flutter/material.dart';
import 'package:itk_app/ui/core/theme/app_spacing.dart';
import 'package:itk_app/ui/core/widgets/adaptive_sheet.dart';

class PickerSearchField extends StatelessWidget {
  const PickerSearchField({
    super.key,
    required this.searchController,
    required this.onChanged,
    required this.hintText,
  });

  final TextEditingController searchController;
  final ValueChanged<String> onChanged;
  final String hintText;
  @override
  Widget build(BuildContext context) {
    final bg = sheetBackgroundColor(context);

    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.screenHorizontal,
        AppSpacing.screenHorizontal,
        AppSpacing.screenHorizontal,
        MediaQuery.paddingOf(context).bottom + AppSpacing.screenHorizontal,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [bg.withValues(alpha: 0.0), bg],
          stops: const [0.0, 0.4],
        ),
      ),
      child: TextField(
        controller: searchController,
        onChanged: onChanged,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: const Icon(Icons.search_rounded),
          suffixIcon: ValueListenableBuilder(
              valueListenable: searchController,
              builder: (context, value, _) {
                return value.text.isEmpty
                    ? const SizedBox.shrink()
                    : IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () {
                          searchController.clear();
                          onChanged('');
                        },
                      );
              }),
        ),
      ),
    );
  }
}
