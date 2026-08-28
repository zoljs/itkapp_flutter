import 'package:itk_app/models/user_site.dart';
import 'package:itk_app/screens/my_site_screen.dart';
import 'package:itk_app/services/auth_service.dart';
import 'package:itk_app/services/sites_service.dart';
import 'package:itk_app/theme/app_colors.dart';
import 'package:itk_app/theme/app_fonts.dart';
import 'package:itk_app/utils/auth_actions.dart';
import 'package:m3e_core/m3e_core.dart';
import 'package:material_ui/material_ui.dart';
import 'package:skeletonizer/skeletonizer.dart';

class WikiScreen extends StatefulWidget {
  const WikiScreen({super.key});

  @override
  State<WikiScreen> createState() => _WikiScreenState();
}

class _WikiScreenState extends State<WikiScreen> {
  final _sitesService = SitesService.instance;
  final _authService = AuthService.instance;

  final _searchController = TextEditingController();
  List<UserSite> _sites = SitesService.instance.cachedSites;
  int? _currentUserId = AuthService.instance.cachedUser?.id;

  bool _loading = !SitesService.instance.hasCachedSites;

  Future<void> _loadCurrentUser() async {
    final user = await _authService.getSessionUser();
    if (!mounted) return;
    setState(() => _currentUserId = user?.id);
  }

  Future<void> _loadSites() async {
    try {
      final sites = await _sitesService.getAllSites();

      if (!mounted) return;

      setState(() {
        _sites = sites;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
      });
    }
  }

  List<UserSite> get _filteredSites {
    final query = _searchController.text.trim().toLowerCase();

    return _sites.where((s) {
      final matchesSearch = query.isEmpty ||
          s.name.toLowerCase().contains(query) ||
          s.tags.any((t) => t.toLowerCase().contains(query)) ||
          s.url.toLowerCase().contains(query);

      return matchesSearch;
    }).toList();
  }

  final _scrollController = ScrollController();

  double _collapseProgress = 0.0;
  static const _collapseRange = 130.0;

  void _onScroll() {
    final progress =
        (_scrollController.offset / _collapseRange).clamp(0.0, 1.0);
    if (progress != _collapseProgress) {
      setState(() => _collapseProgress = progress);
    }
  }

  @override
  void initState() {
    super.initState();
    _loadSites();
    _loadCurrentUser();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Widget _buildMySiteCard() {
    final scheme = Theme.of(context).colorScheme;
    UserSite? site;
    for (final s in _sites) {
      if (s.userId == _currentUserId && _currentUserId != null) {
        site = s;
        break;
      }
    }

    // No own site yet
    if (site == null) {
      return SizedBox(
        height: 80,
        child: Material(
          color: scheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(24.5),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MySiteScreen()),
            ),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  Icon(Icons.add_circle_outline_rounded, color: scheme.primary),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Még nincs saját wiki-oldalad, hozz létre egyet!',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded,
                      color: scheme.onSurfaceVariant),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final color = scheme.primary;

    // Own site
    return Container(
      height: 80,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.lerp(color, Colors.black, 0.05)!,
            color.withValues(alpha: 0.5),
          ],
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24.5),
        clipBehavior: Clip.antiAlias,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24.5),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color,
                Color.lerp(color, Colors.black, 0.12)!,
              ],
            ),
          ),
          child: InkWell(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MySiteScreen()),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: Colors.white.withValues(alpha: 0.25),
                    child: Text(
                      site.name.isNotEmpty ? site.name[0].toUpperCase() : '?',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        color: kTextDark,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.35),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'SAJÁT OLDALAM',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.4,
                              color: kTextDark,
                            ),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          site.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.italic,
                            color: kTextDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const MySiteScreen()),
                    ),
                    iconSize: 22,
                    padding: EdgeInsets.zero,
                    icon: const Icon(Icons.edit_rounded, color: kTextDark),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSiteCard(UserSite site, int index) {
    Color color = Theme.of(context).colorScheme.primary;
    final own = site.userId == _currentUserId;

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.lerp(color, Colors.white, 0.5)!,
            color.withValues(alpha: 0.5),
          ],
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24.5),
        clipBehavior: Clip.antiAlias,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24.5),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color,
                Color.lerp(color, Colors.black, 0.12)!,
              ],
            ),
          ),
          child: InkWell(
            onTap: () {},
            borderRadius: BorderRadius.circular(24.5),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          site.name,
                          style: const TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.italic,
                            color: kTextDark,
                          ),
                        ),
                      ),
                      Image.asset(
                        'assets/icons/itk-small.png',
                        height: 30,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: site.tags.take(4).map((tag) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .onPrimaryContainer
                              .withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Skeleton.ignore(
                          child: Text(
                            tag,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: kTextGray,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          Uri.tryParse(site.url)?.host ?? site.url,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style:
                              const TextStyle(fontSize: 12, color: kTextGray),
                        ),
                      ),
                      own
                          ? IconButton(
                              onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const MySiteScreen())),
                              iconSize: 24,
                              padding: EdgeInsets.zero,
                              icon: const Icon(
                                Icons.edit_rounded,
                                color: kTextDark,
                              ),
                            )
                          : const SizedBox.shrink(),
                      const SizedBox(width: 8),
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceContainerLowest
                              .withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Skeleton.ignore(
                          child: Icon(
                            Icons.arrow_forward_rounded,
                            color: kTextDark,
                            size: 24,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Full size is 320: 260 + 60 preferredSize height
    const collapsedHeight = 80.0;
    const expandedHeight = 260.0;
    const preferredSizeHeight = 60.0;
    const fullHeight = expandedHeight + preferredSizeHeight;
    const halfHeight = fullHeight / 2;
    const separatorOffset = 20.0;
    const cardAlignY = separatorOffset / 100.0;
    const separatorHeight = halfHeight + separatorOffset;

    final displaySites = _loading
        ? List.filled(
            4,
            UserSite(
              userId: -1,
              name: BoneMock.name,
              url: 'https://example.com/${BoneMock.words(1)}',
              tags: [BoneMock.words(1), BoneMock.words(1)],
              category: 'wip',
            ),
          )
        : _filteredSites;

    return Scaffold(
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: () async {
              setState(() => _loading = true);
              final sites = await _sitesService.getAllSites(forceReload: true);
              if (!mounted) return;
              setState(() {
                _sites = sites;
                _loading = false;
              });
            },
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                SliverAppBar(
                  title: Text(
                    'Users Oldalak',
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.merge(topBarTitleStyle),
                  ),
                  expandedHeight: expandedHeight,
                  collapsedHeight: collapsedHeight,
                  floating: true,
                  pinned: true,
                  scrolledUnderElevation: 0,
                  // backgroundColor: Colors.amber, //test
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  actionsPadding: const EdgeInsets.all(8),
                  actions: [
                    IconButton(
                      onPressed: () => performLogout(context),
                      icon: Icon(Icons.logout_rounded,
                          color: Theme.of(context).colorScheme.onSurface,
                          size: 20),
                      style: IconButton.styleFrom(
                        backgroundColor:
                            Theme.of(context).colorScheme.surfaceContainer,
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(10),
                      ),
                    ),
                  ],
                  bottom: PreferredSize(
                    preferredSize: const Size.fromHeight(preferredSizeHeight),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (_) => setState(() {}),
                        decoration: const InputDecoration(
                          hintText: 'Oldal, tantárgy neve...',
                          prefixIcon: Icon(Icons.search_rounded),
                        ),
                      ),
                    ),
                  ),
                  flexibleSpace: FlexibleSpaceBar(
                    collapseMode: CollapseMode.pin,
                    background: Stack(
                      children: [
                        Align(
                          alignment: Alignment.topCenter,
                          child: Container(
                            height: separatorHeight,
                            color:
                                Theme.of(context).colorScheme.primaryContainer,
                          ),
                        ),
                        Align(
                          // Push by 20px
                          alignment: const Alignment(0, cardAlignY),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: _loading
                                ? Container(
                                    width: double.infinity,
                                    height: 80,
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .surfaceContainerHigh,
                                      borderRadius: BorderRadius.circular(24.5),
                                    ),
                                    child:
                                        const M3ECircularWavyProgressIndicator(),
                                  )
                                : _buildMySiteCard(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 140),
                  sliver: Skeletonizer.sliver(
                    enabled: _loading,
                    child: SliverList.separated(
                      itemCount: displaySites.length,
                      itemBuilder: (context, index) =>
                          _buildSiteCard(displaySites[index], index),
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 10),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
