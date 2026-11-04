import 'package:flutter/material.dart';
import 'package:itk_app/ui/core/theme/app_spacing.dart';

class AppSearchField extends StatelessWidget {
  const AppSearchField({
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
    return SizedBox(
      height: AppSpacing.searchFieldHeight,
      child: TextField(
        expands: true,
        minLines: null,
        maxLines: null,
        textAlignVertical: TextAlignVertical.center,
        textInputAction: TextInputAction.search,
        controller: searchController,
        onChanged: onChanged,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.zero,
          hintText: hintText,
          prefixIcon: const Icon(Icons.search_rounded),
          suffixIcon: searchController.text.isEmpty
              ? null
              : IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () {
                    searchController.clear();
                    onChanged('');
                  },
                ),
        ),
      ),
    );
  }
}
