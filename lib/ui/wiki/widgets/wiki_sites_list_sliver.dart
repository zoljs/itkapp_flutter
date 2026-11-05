import 'package:flutter/material.dart';
import 'package:itk_app/domain/models/user_site.dart';
import 'package:itk_app/ui/core/theme/app_spacing.dart';
import 'package:itk_app/ui/core/widgets/sliver_state_message.dart';
import 'package:itk_app/ui/wiki/widgets/site_list_card.dart';
import 'package:skeletonizer/skeletonizer.dart';

class WikiSitesListSliver extends StatelessWidget {
  const WikiSitesListSliver({
    super.key,
    required this.searchController,
    required this.loading,
    this.loadError,
    this.checkingLogin,
    required this.query,
    required this.sites,
    required this.onRetry,
    required this.onSiteTap,
  });

  final TextEditingController searchController;
  final bool loading; // _viewModel.sitesInitialLoading;
  final String? loadError; // _viewModel.load.errorMessage
  final String? checkingLogin;
  final String query; // _searchController.text.trim() // trimmed
  final List<UserSite> sites; // _viewModel.filteredSites
  final VoidCallback onRetry; // () => _viewModel.load.execute(true)
  final ValueChanged<UserSite> onSiteTap; // _onSiteTap(site)

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        final displaySites = loading
            ? List.filled(
                4,
                UserSite(
                  claimed: true,
                  name: BoneMock.name,
                  url: 'https://example.com/${BoneMock.words(1)}',
                  tags: [
                    BoneMock.words(1),
                    BoneMock.words(1),
                  ],
                ),
              )
            : sites;

        if (!loading && displaySites.isEmpty) {
          final (icon, message) = switch ((
            loadError,
            query.isEmpty,
          )) {
            (final String error, _) => (Icons.cloud_off_rounded, error),
            (null, true) => (Icons.hourglass_empty, 'Még nincs oldal.'),
            (null, false) => (
                Icons.search_off_rounded,
                'Nincs találat erre: „$query”'
              ),
          };

          return SliverStateMessage(
            icon: icon,
            message: message,
            onRetry: loadError == null ? null : onRetry,
          );
        }

        return SliverPadding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.screenHorizontal, 0,
              AppSpacing.screenHorizontal, AppSpacing.bottomNavClearance),
          sliver: Skeletonizer.sliver(
            enabled: loading,
            child: SliverList.separated(
              itemCount: displaySites.length,
              itemBuilder: (context, index) {
                final site = displaySites[index];
                return SiteListCard(
                  site: site,
                  checking:
                      checkingLogin != null && checkingLogin == site.login,
                  onTap: () => onSiteTap(site),
                );
              },
              separatorBuilder: (context, index) =>
                  const SizedBox(height: AppSpacing.lg),
            ),
          ),
        );
      },
    );
  }
}
