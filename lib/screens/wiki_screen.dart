import 'package:itk_app/models/user_site.dart';
import 'package:itk_app/screens/my_site_screen.dart';
import 'package:itk_app/services/auth_service.dart';
import 'package:itk_app/services/sites_service.dart';
import 'package:itk_app/theme/app_fonts.dart';
import 'package:itk_app/theme/app_radius.dart';
import 'package:itk_app/theme/app_spacing.dart';
import 'package:itk_app/theme/app_themes.dart';
import 'package:itk_app/widgets/platform_appbar.dart';
import 'package:itk_app/widgets/my_site_card.dart';
import 'package:itk_app/widgets/user_site_card.dart';
import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

class WikiScreen extends StatefulWidget {
  const WikiScreen({super.key});

  @override
  State<WikiScreen> createState() => _WikiScreenState();
}

class _WikiScreenState extends State<WikiScreen> {
  final _searchController = TextEditingController();

  final int? _currentUserId = AuthService.instance.cachedUser?.id;
  List<UserSite> _sites = SitesService.instance.cachedSites;
  UserSite? get _mySite {
    if (_currentUserId == null) return null;
    for (final s in _sites) {
      if (s.userId == _currentUserId) return s;
    }
    return null;
  }

  bool _loading = !SitesService.instance.hasCachedSites;

  @override
  void initState() {
    super.initState();
    if (!SitesService.instance.hasCachedSites) {
      _loadAll();
    }
  }

  Future<void> _loadAll({bool forceReload = false}) async {
    if (!SitesService.instance.hasCachedSites || forceReload) {
      setState(() => _loading = true);
    }

    try {
      final sites =
          await SitesService.instance.getAllSites(forceReload: forceReload);

      if (!mounted) return;
      setState(() {
        _sites = sites;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
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

  Future<void> _openMySite() async {
    await Navigator.push(
        context, MaterialPageRoute(builder: (context) => const MySiteScreen()));

    _loadAll();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Widget _buildSiteCard(UserSite site, int index) {
    final own = site.userId == _currentUserId;

    return UserSiteCard(
      color: itkPrimary,
      onTap: () {},
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
                    color: Colors.black87,
                  ),
                ),
              ),
              Skeleton.ignore(
                child: Image.asset(
                  'assets/icons/itk-small.png',
                  height: 30,
                ),
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
                    horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Skeleton.ignore(
                  child: Text(
                    tag,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
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
                  style: const TextStyle(fontSize: 12, color: Colors.black87),
                ),
              ),
              own
                  ? IconButton(
                      highlightColor: Colors.white.withValues(alpha: 0.25),
                      onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const MySiteScreen())),
                      iconSize: 24,
                      padding: EdgeInsets.zero,
                      icon: const Icon(
                        Icons.edit_rounded,
                        color: Colors.black87,
                      ),
                    )
                  : const SizedBox.shrink(),
              const SizedBox(width: 8),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.25),
                  shape: BoxShape.circle,
                ),
                child: const Skeleton.ignore(
                  child: Icon(
                    Icons.arrow_forward_rounded,
                    color: Colors.black87,
                    size: 24,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: () => _loadAll(forceReload: true),
            child: CustomScrollView(
              slivers: [
                ShrinkingSliverAppBar(
                  centerTitle: false,
                  title: Text(
                    'ITK Wiki 3 Beta',
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.merge(topBarTitleStyle),
                  ),
                  preferredSizeChild: Padding(
                    padding: const EdgeInsets.fromLTRB(
                        AppSpacing.screenHorizontal,
                        0,
                        AppSpacing.screenHorizontal,
                        AppSpacing.screenHorizontal),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (_) => setState(() {}),
                      decoration: const InputDecoration(
                        hintText: 'Oldal, tantárgy neve...',
                        prefixIcon: Icon(Icons.search_rounded),
                      ),
                    ),
                  ),
                  centeredWidget: Padding(
                    padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
                    child: _loading
                        ? Container(
                            width: double.infinity,
                            height: 80,
                            alignment: Alignment.center,
                            padding: const EdgeInsets.all(
                                AppSpacing.screenHorizontal),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHigh,
                              borderRadius:
                                  BorderRadius.circular(AppRadius.xxl),
                            ),
                            child: const CircularProgressIndicator.adaptive(),
                          )
                        : MySiteCard(mySite: _mySite, openMySite: _openMySite),
                  ),
                  hasSearchBar: true,
                ),
                Builder(
                  builder: (context) {
                    final displaySites = _loading
                        ? List.filled(
                            4,
                            UserSite(
                              userId: -1,
                              name: BoneMock.name,
                              url: 'https://example.com/${BoneMock.words(1)}',
                              tags: [
                                BoneMock.words(1),
                                BoneMock.words(1),
                              ],
                              category: 'wip',
                            ),
                          )
                        : _filteredSites;

                    return SliverPadding(
                      padding: const EdgeInsets.fromLTRB(
                          AppSpacing.screenHorizontal,
                          0,
                          AppSpacing.screenHorizontal,
                          AppSpacing.bottomNavClearance),
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
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
