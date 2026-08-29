import 'package:itk_app/theme/app_theme_colors.dart';
import 'package:itk_app/utils/auth_actions.dart';
import 'package:material_ui/material_ui.dart';

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
    const fullHeight = expandedHeight + preferredSizeHeight;

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
                actionsPadding: const EdgeInsets.symmetric(horizontal: 16),
                actions: [
                  SizedBox(
                    width: 40,
                    height: 40,
                    child: IconButton(
                      onPressed: () => performLogout(context),
                      icon: Icon(Icons.logout_rounded,
                          color: Theme.of(context).colorScheme.onSurface,
                          size: 20),
                      style: IconButton.styleFrom(
                        backgroundColor:
                            Theme.of(context).colorScheme.surfaceContainer,
                        shape: const CircleBorder(),
                        padding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                ],
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
                    padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
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
                        color: Theme.of(context)
                            .colorScheme
                            .onPrimary
                            .withValues(alpha: 0.25),
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
          children: [
            const Placeholder(),
            _buildNewsTab(),
            const Placeholder(),
          ],
        ),
      ),
    );
  }

  Widget _buildNewsTab() {
    return Builder(builder: (context) {
      return CustomScrollView(
        key: const PageStorageKey('Hírek tab'),
        slivers: [
          SliverOverlapInjector(
              handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context)),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList.separated(
              itemCount: 10,
              itemBuilder: (context, index) {
                return _buildNewsCard();
              },
              separatorBuilder: (context, index) => const Divider(
                height: 16,
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildNewsCard() {
    return Builder(builder: (context) {
      return SizedBox(
        height: 150,
        child: Material(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(20),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () {},
            borderRadius: BorderRadius.circular(20),
            splashColor: Theme.of(context)
                .extension<AppThemeColors>()!
                .textDark
                .withValues(alpha: 0.12),
            highlightColor: Theme.of(context)
                .extension<AppThemeColors>()!
                .textDark
                .withValues(alpha: 0.06),
          ),
        ),
      );
    });
  }
}
