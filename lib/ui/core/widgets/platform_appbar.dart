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
    this.hasSearchBar = false,
  });

  final Widget? preferredSizeChild;
  final List<Widget>? actions;
  final Widget? title;
  final Widget? flexibleSpaceBarTitle;
  final Widget? centeredWidget;
  final bool hasSearchBar;

  final bool centerTitle;

  @override
  Widget build(BuildContext context) {
    //final isIOS = Theme.of(context).platform == TargetPlatform.iOS;
    const isIOS = false;

    const collapsedHeight = 60.0;
    final idk = isIOS && hasSearchBar ? 0.0 : 70.0; // ignore: dead_code
    final expandedHeight = 190.0 + idk;
    final preferredSizeHeight =
        isIOS && hasSearchBar ? 0.0 : 60.0; // ignore: dead_code
    final separatorOffset =
        isIOS && hasSearchBar ? 85 : 20.0; // ignore: dead_code

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
      // backgroundColor: Colors.amber, //test
      backgroundColor: Theme.of(context).colorScheme.surface,
      actions: [
        ...?actions,
      ],
      actionsPadding:
          const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
      bottom: !isIOS && hasSearchBar
          ? PreferredSize(
              preferredSize: Size.fromHeight(preferredSizeHeight),
              child: preferredSizeChild!,
            )
          : null,
      flexibleSpace: FlexibleSpaceBar(
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
                  color: Theme.of(context).colorScheme.primaryContainer,
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
    );
  }
}
