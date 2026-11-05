import 'package:flutter/material.dart';
import 'package:itk_app/domain/models/site_color.dart';
import 'package:itk_app/ui/core/theme/app_spacing.dart';
import 'package:itk_app/ui/core/theme/site_colors.dart';
import 'package:itk_app/ui/core/widgets/grouped_list.dart';

class MySiteColorPicker extends StatelessWidget {
  const MySiteColorPicker({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final SiteColor selected;
  final ValueChanged<SiteColor> onSelected;

  @override
  Widget build(BuildContext context) {
    return SettingsGroup(
      header: 'Megjelenés',
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Row(
              children: SiteColor.values.map((siteColor) {
                final color = siteColor.color;
                final isSelected = siteColor == selected;
                final double borderRadius = isSelected ? 12.0 : 28.0;
                final double innerBorderRadius = isSelected ? 6.0 : 20.0;

                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => onSelected(siteColor),
                    child: AnimatedContainer(
                      curve: Curves.easeInOutCubic,
                      duration: const Duration(milliseconds: 300),
                      height: 56,
                      width: 56,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(borderRadius),
                        border: Border.all(
                          color: isSelected ? color : Colors.transparent,
                          width: 4,
                        ),
                      ),
                      child: AnimatedContainer(
                        curve: Curves.easeInOutCubic,
                        duration: const Duration(milliseconds: 300),
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              color,
                              Color.lerp(color, Colors.black, 0.4)!,
                            ],
                          ),
                          borderRadius:
                              BorderRadius.circular(innerBorderRadius),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}
