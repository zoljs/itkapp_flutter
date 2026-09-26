import 'package:itk_app/theme/app_spacing.dart';
import 'package:material_ui/material_ui.dart';

class AdaptiveAppBar extends StatelessWidget {
  const AdaptiveAppBar({
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
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;

    const collapsedHeight = 60.0;
    final idk = isIOS && hasSearchBar ? 0.0 : 70.0;
    final expandedHeight = 190.0 + idk;
    final preferredSizeHeight = isIOS && hasSearchBar ? 0.0 : 60.0;
    final fullHeight = expandedHeight + preferredSizeHeight;
    final halfHeight = fullHeight / 2;
    final separatorOffset = isIOS && hasSearchBar ? 85 : 20.0;
    final separatorHeight = halfHeight + separatorOffset;

    return SliverAppBar(
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
        collapseMode: CollapseMode.pin,
        title: flexibleSpaceBarTitle,
        centerTitle: true,
        background: Stack(
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                height: separatorHeight,
                color: Theme.of(context).colorScheme.primaryContainer,
              ),
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
      ),
    );
  }
}
