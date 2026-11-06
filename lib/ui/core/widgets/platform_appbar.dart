import 'package:itk_app/ui/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:itk_app/ui/core/widgets/brand_appbar.dart';

class ShrinkingSliverAppBar extends StatelessWidget {
  const ShrinkingSliverAppBar({
    super.key,
    this.bottom,
    this.actions,
    this.title,
    this.centerTitle = false,
    this.flexibleSpaceBarTitle,
    this.centeredWidget,
    this.hasBackButton = false,
    this.expandedHeight = 260,
    this.divider,
  });

  final Widget? bottom;
  final List<Widget>? actions;
  final Widget? title;
  final Widget? flexibleSpaceBarTitle;
  final Widget? centeredWidget;
  final bool hasBackButton;
  final double expandedHeight;
  final bool centerTitle;
  final double? divider;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return SliverAppBar(
      centerTitle: centerTitle,
      title: title,
      expandedHeight: expandedHeight,
      pinned: true,
      scrolledUnderElevation: 0,
      backgroundColor: scheme.surface,
      actions: [
        ...?actions,
      ],
      leading: hasBackButton
          ? Padding(
              padding: const EdgeInsets.only(left: AppSpacing.sm),
              child: buildBrandLeading(context, closesSheet: false),
            )
          : null,
      actionsPadding:
          const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
      bottom: bottom == null
          ? null
          : PreferredSize(
              preferredSize: const Size.fromHeight(AppSpacing.searchBarHeight),
              child: bottom!,
            ),
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [
          StretchMode.zoomBackground,
        ],
        collapseMode: CollapseMode.pin,
        title: flexibleSpaceBarTitle,
        centerTitle: true,
        background: LayoutBuilder(
          builder: (context, constraints) {
            // Standard searchbar height + half of card
            final bottomHeight = divider ??
                (bottom == null
                    ? expandedHeight / 2
                    : AppSpacing.searchFieldHeight +
                        AppSpacing.md * 2 +
                        AppSpacing.mySiteCardHeight / 2);

            final separatorHeight = (constraints.maxHeight - bottomHeight)
                .clamp(0.0, double.infinity);

            return Align(
              alignment: Alignment.topCenter,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: separatorHeight,
                    child: ColoredBox(color: scheme.primaryContainer),
                  ),
                  Positioned(
                    top: separatorHeight,
                    left: 0,
                    right: 0,
                    child: FractionalTranslation(
                      translation: const Offset(0.0, -0.5),
                      child: centeredWidget,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
