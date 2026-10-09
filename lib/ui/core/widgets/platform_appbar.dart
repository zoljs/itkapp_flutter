import 'package:itk_app/ui/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';

class ShrinkingSliverAppBar extends StatelessWidget {
  const ShrinkingSliverAppBar({
    super.key,
    this.preferredSizeChild,
    this.actions,
    this.title,
    this.centerTitle = false,
    this.flexibleSpaceBarTitle,
    this.centeredWidget,
  });

  final Widget? preferredSizeChild;
  final List<Widget>? actions;
  final Widget? title;
  final Widget? flexibleSpaceBarTitle;
  final Widget? centeredWidget;

  final bool centerTitle;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    const collapsedHeight = 60.0;
    const expandedHeight = 260.0;

    return SliverAppBar(
      stretch: true,
      stretchTriggerOffset: 100.0,
      centerTitle: centerTitle,
      title: title,
      expandedHeight: expandedHeight,
      collapsedHeight: collapsedHeight,
      floating: true,
      pinned: true,
      scrolledUnderElevation: 0,
      backgroundColor: scheme.surface,
      actions: [
        ...?actions,
      ],
      actionsPadding:
          const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
      bottom: preferredSizeChild == null
          ? null
          : PreferredSize(
              preferredSize:
                  const Size.fromHeight(AppSpacing.searchFieldHeight),
              child: preferredSizeChild!,
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
            final bottomHeight = preferredSizeChild == null
                ? 130.0
                : AppSpacing.searchBarHeight + AppSpacing.mySiteCardHeight / 2;

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
