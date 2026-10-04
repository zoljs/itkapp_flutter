import 'package:itk_app/domain/models/user_site.dart';
import 'package:itk_app/ui/core/widgets/state_message.dart';
import 'package:itk_app/ui/wiki/my_site_screen.dart';
import 'package:itk_app/data/services/auth_service.dart';
import 'package:itk_app/data/services/sites_service.dart';
import 'package:itk_app/ui/core/theme/app_fonts.dart';
import 'package:itk_app/ui/core/theme/app_radius.dart';
import 'package:itk_app/ui/core/theme/app_spacing.dart';
import 'package:itk_app/ui/core/theme/app_themes.dart';
import 'package:itk_app/ui/core/widgets/platform_appbar.dart';
import 'package:itk_app/ui/core/widgets/my_site_card.dart';
import 'package:itk_app/ui/wiki/widgets/user_site_card.dart';
import 'package:flutter/material.dart';
import 'package:itk_app/utils/context_extensions.dart';
import 'package:itk_app/utils/result.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:url_launcher/url_launcher.dart';

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

  String? _error;
  Future<void> _loadAll({bool forceReload = false}) async {
    setState(() {
      _error = null;
      if (!SitesService.instance.hasCachedSites || forceReload) _loading = true;
    });

    final result =
        await SitesService.instance.getAllSites(forceReload: forceReload);
    if (!mounted) return;

    switch (result) {
      case Ok(:final value):
        setState(() {
          _sites = value;
          _loading = false;
        });
      case Err(:final message):
        setState(() {
          _error = message;
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

  Future<void> _openMySite() async {
    await Navigator.push(
        context, MaterialPageRoute(builder: (context) => const MySiteScreen()));

    _loadAll();
  }

  Future<void> _openSite(String url) async {
    final uri = Uri.tryParse(url);
    final ok = uri != null &&
        uri.hasScheme &&
        await launchUrl(uri, mode: LaunchMode.inAppWebView);

    if (!ok && mounted) {
      context.showMessage('Nem sikerült megnyitni az oldalt.');
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Widget _buildSiteCard(UserSite site, int index) {
    return UserSiteCard(
      color: itkPrimary,
      onTap: () => _openSite(site.url),
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
          const SizedBox(height: AppSpacing.lg),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
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
          const SizedBox(height: AppSpacing.lg),
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
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => _loadAll(forceReload: true),
        child: CustomScrollView(
          // ios bounce physics even if the list does NOT overflow
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          slivers: [
            ShrinkingSliverAppBar(
              middleValue: .8,
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
                  decoration: InputDecoration(
                    hintText: 'Oldal, tantárgy neve...',
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: _searchController.text.isEmpty
                        ? null
                        : IconButton(
                            icon: const Icon(Icons.close_rounded),
                            onPressed: () => setState(_searchController.clear),
                          ),
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
                        padding:
                            const EdgeInsets.all(AppSpacing.screenHorizontal),
                        decoration: BoxDecoration(
                          color: scheme.surfaceContainerHigh,
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                        ),
                        child: const CircularProgressIndicator(),
                      )
                    : MySiteCard(mySite: _mySite, openMySite: _openMySite),
              ),
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
                        ),
                      )
                    : _filteredSites;

                if (!_loading && (_error != null || displaySites.isEmpty)) {
                  final query = _searchController.text.trim();

                  final (icon, message) = switch ((_error, query.isEmpty)) {
                    (final String error, _) => (Icons.cloud_off_rounded, error),
                    (null, true) => (Icons.hourglass_empty, 'Még nincs oldal.'),
                    (null, false) => (
                        Icons.search_off_rounded,
                        'Nincs találat erre: „$query”'
                      ),
                  };

                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        AppSpacing.xxl,
                        AppSpacing.xxl,
                        AppSpacing.xxl,
                        MediaQuery.paddingOf(context).bottom + AppSpacing.lg,
                      ),
                      child: StateMessage(
                        icon: icon,
                        message: message,
                        onRetry: _error != null
                            ? () => _loadAll(forceReload: true)
                            : null,
                      ),
                    ),
                  );
                }

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
                          const SizedBox(height: AppSpacing.lg),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
