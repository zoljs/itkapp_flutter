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
    this.middleValue = .65,
  });

  final Widget? preferredSizeChild;
  final List<Widget>? actions;
  final Widget? title;
  final Widget? flexibleSpaceBarTitle;
  final Widget? centeredWidget;
  final double middleValue;

  final bool centerTitle;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    const collapsedHeight = 60.0;
    const expandedHeight = 260.0;
    const preferredSizeHeight = 60.0;
    const separatorOffset = 20.0;

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
      backgroundColor: Colors.transparent,
      actions: [
        ...?actions,
      ],
      actionsPadding:
          const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
      bottom: preferredSizeChild == null
          ? null
          : PreferredSize(
              preferredSize: const Size.fromHeight(preferredSizeHeight),
              child: preferredSizeChild!,
            ),
      flexibleSpace: Stack(
        fit: StackFit.expand,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  scheme.surface,
                  scheme.surface,
                  scheme.surface.withValues(alpha: 0.0),
                ],
                stops: [0.0, middleValue, 1.0],
              ),
            ),
          ),
          FlexibleSpaceBar(
            stretchModes: const [
              StretchMode.zoomBackground,
            ],
            collapseMode: CollapseMode.pin,
            title: flexibleSpaceBarTitle,
            centerTitle: true,
            background: LayoutBuilder(
              builder: (context, constraints) {
                // constraints.maxHeight grows dynamically as the user pulls down
                final currentHeight = constraints.maxHeight;
                final dynamicSeparatorHeight =
                    (currentHeight / 2) + separatorOffset;

                return Stack(
                  children: [
                    Container(
                      height: dynamicSeparatorHeight,
                      width: double.infinity,
                      color: scheme.primaryContainer,
                    ),
                    Positioned(
                      top: dynamicSeparatorHeight,
                      left: 0,
                      right: 0,
                      child: FractionalTranslation(
                        translation: const Offset(0.0, -0.5),
                        child: centeredWidget,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
