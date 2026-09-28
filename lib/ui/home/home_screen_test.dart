import 'package:itk_app/ui/core/theme/app_spacing.dart';

import 'package:flutter/material.dart';

class HomeScreenTest extends StatefulWidget {
  const HomeScreenTest({super.key});

  @override
  State<HomeScreenTest> createState() => _HomeScreenTestState();
}

class _HomeScreenTestState extends State<HomeScreenTest>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  static const _tabs = ['Valami', 'Hírek', 'Linkek'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Full size is 320: 260 + 60 preferredSize height
    const collapsedHeight = 60.0;
    const expandedHeight = 150.0;
    const preferredSizeHeight = 56.0;
    // const fullHeight = expandedHeight + preferredSizeHeight;

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverOverlapAbsorber(
              handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
              sliver: SliverAppBar(
                toolbarHeight: preferredSizeHeight,
                expandedHeight: expandedHeight,
                collapsedHeight: collapsedHeight,
                scrolledUnderElevation: 0,
                backgroundColor: Theme.of(context).colorScheme.surface,
                actionsPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenHorizontal),
                title: Builder(builder: (context) {
                  final settings = context.dependOnInheritedWidgetOfExactType<
                      FlexibleSpaceBarSettings>();

                  double opacity = 0.0;

                  if (settings != null) {
                    final deltaExtent = settings.maxExtent - settings.minExtent;
                    final t = (settings.currentExtent - settings.minExtent) /
                        deltaExtent;
                    opacity = 1.0 - t.clamp(0.0, 1.0);
                  }

                  return Opacity(
                    opacity: opacity,
                    child: RepaintBoundary(
                      child: Image.asset(
                        'assets/icons/itkapp-small.png',
                        height: 30,
                      ),
                    ),
                  );
                }),
                pinned: true,
                snap: false,
                flexibleSpace: FlexibleSpaceBar(
                  collapseMode: CollapseMode.pin,
                  titlePadding: const EdgeInsets.only(bottom: 90),
                  background: Builder(
                    builder: (context) {
                      final settings =
                          context.dependOnInheritedWidgetOfExactType<
                              FlexibleSpaceBarSettings>();
                      double opacity = 0.0;
                      if (settings != null) {
                        final deltaExtent =
                            settings.maxExtent - settings.minExtent;
                        final t =
                            (settings.currentExtent - settings.minExtent) /
                                deltaExtent;
                        final scaledT = ((t - 0.6) / 0.4).clamp(0.0, 1.0);
                        opacity = scaledT;
                      }

                      return Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .primaryContainer,
                            ),
                          ),
                          Center(
                            child: Opacity(
                              opacity: opacity,
                              child: RepaintBoundary(
                                child: Image.asset(
                                  'assets/icons/itkapp-small.png',
                                  height: 45,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(preferredSizeHeight + 8),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                        AppSpacing.sm, 0, AppSpacing.sm, AppSpacing.sm),
                    child: TabBar(
                      splashBorderRadius: BorderRadius.circular(50),
                      dividerColor: Colors.transparent,
                      physics: const BouncingScrollPhysics(),
                      indicatorSize: TabBarIndicatorSize.tab,
                      controller: _tabController,
                      tabs: _tabs.map((t) => Tab(text: t)).toList(),
                      indicator: BoxDecoration(
                        border: Border.all(color: Colors.transparent, width: 8),
                        borderRadius: BorderRadius.circular(50.0),
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: const [
            Placeholder(),
            Placeholder(),
            Placeholder(),
          ],
        ),
      ),
    );
  }
}
