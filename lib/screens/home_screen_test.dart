import 'package:itk_app/theme/app_colors.dart';
import 'package:material_ui/material_ui.dart';

class HomeScreenTest extends StatefulWidget {
  const HomeScreenTest({super.key});

  @override
  State<HomeScreenTest> createState() => _HomeScreenTestState();
}

class _HomeScreenTestState extends State<HomeScreenTest>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  static const _tabs = ['Naptár', 'Hírek', 'Gyors linkek'];

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
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverOverlapAbsorber(
              handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
              sliver: SliverAppBar(
                expandedHeight: 100,
                flexibleSpace: FlexibleSpaceBar(
                  centerTitle: true,
                  titlePadding: const EdgeInsets.only(bottom: 50),
                  title: Builder(
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

                        opacity = t.clamp(0.0, 1.0);
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
                    },
                  ),
                  background: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                    ),
                  ),
                ),
                floating: true,
                pinned: true,
                snap: false,
                bottom: TabBar(
                  indicatorSize: TabBarIndicatorSize.tab,
                  controller: _tabController,
                  tabs: _tabs.map((t) => Tab(text: t)).toList(),
                  indicator: BoxDecoration(
                      border:
                          BoxBorder.all(color: Colors.transparent, width: 8),
                      borderRadius: BorderRadius.circular(
                        25.0,
                      ),
                      color: Theme.of(context)
                          .colorScheme
                          .onPrimary
                          .withValues(alpha: 0.25)),
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
            splashColor: kTextDark.withValues(alpha: 0.12),
            highlightColor: kTextDark.withValues(alpha: 0.06),
          ),
        ),
      );
    });
  }
}
