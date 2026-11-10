import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:itk_app/data/repositories/auth_repository.dart';
import 'package:itk_app/data/repositories/wiki_sites_repository.dart';
import 'package:itk_app/data/repositories/wiki_files_repository.dart';
import 'package:itk_app/routing/routes.dart';
import 'package:itk_app/ui/core/widgets/app_search_field.dart';
import 'package:itk_app/ui/core/widgets/settings_avatar_button.dart';
import 'package:itk_app/ui/wiki/widgets/wiki_sites_list_sliver.dart';
import 'package:itk_app/utils/open_link.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:itk_app/domain/models/user_site.dart';
import 'package:itk_app/ui/wiki/viewmodels/wiki_viewmodel.dart';

import 'package:itk_app/ui/core/theme/app_fonts.dart';
import 'package:itk_app/ui/core/theme/app_spacing.dart';

import 'package:itk_app/ui/core/widgets/platform_appbar.dart';
import 'package:itk_app/ui/wiki/widgets/my_site_card.dart';

class WikiScreen extends StatefulWidget {
  const WikiScreen({super.key});

  @override
  State<WikiScreen> createState() => _WikiScreenState();
}

class _WikiScreenState extends State<WikiScreen> {
  final _searchController = TextEditingController();
  late final WikiViewModel _viewModel;

  Future<void> _openMySite() async {
    await context.push(Routes.wikiEdit);
    await _viewModel.load.execute(false);
  }

  @override
  void initState() {
    super.initState();
    _viewModel = WikiViewModel(
      wikiSitesRepository: context.read<WikiSitesRepository>(),
      wikiFilesRepository: context.read<WikiFilesRepository>(),
      authRepository: context.read<AuthRepository>(),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _onSiteTap(UserSite site) async {
    if (_viewModel.checkFiles.running) return;

    // A site might be unclaimed meaning it might not have a login field
    final login = site.login;
    // If there is no login, it is unclaimed so open the link without looking for a php file, because there is no way its already there if they are not using the app.
    if (login == null) {
      await openLink(context, site.url, mode: LaunchMode.inAppBrowserView);
      return;
    }

    // If there is a login, it means theres a possibility they added the php file.
    await _viewModel.checkFiles.execute(login);
    if (!mounted) return;

    if (_viewModel.checkFiles.completed) {
      await context.push(Routes.filesFor(login));
    } else {
      await openLink(context, site.url, mode: LaunchMode.inAppBrowserView);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;

    return Scaffold(
      body: ListenableBuilder(
          listenable: _viewModel,
          builder: (context, _) {
            final customScrollView = CustomScrollView(
              slivers: [
                // [ShrinkingSliverAppBar] contains your site card and title.
                ShrinkingSliverAppBar(
                  centerTitle: true,
                  expandedHeight: 242,
                  title: Text(
                    'Users Wiki',
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.merge(topBarTitleStyle),
                  ),
                  actions: [
                    SettingsAvatarButton(
                      onAvatarTap: () => context.push(Routes.settings),
                      login: _viewModel.login,
                    )
                  ],
                  bottom: Padding(
                    padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
                    child: AppSearchField(
                      searchController: _searchController,
                      onChanged: _viewModel.setQuery,
                      hintText: 'Oldal, tantárgy neve...',
                    ),
                  ),
                  centeredWidget: Padding(
                    padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
                    child: Skeletonizer(
                      enabled: _viewModel.mySiteInitialLoading,
                      child: MySiteCard(
                        mySite: _viewModel.mySite,
                        onOpen: (site) => unawaited(_onSiteTap(site)),
                        onEdit: _openMySite,
                      ),
                    ),
                  ),
                ),
                // [CupertinoSliverRefreshControl] is the iOS specific pull-to-refresh indicator.
                if (isIOS)
                  CupertinoSliverRefreshControl(
                    onRefresh: () async {
                      await _viewModel.load.execute(true);
                    },
                  ),
                // [WikiSitesListSliver] is a dumb widget. It displays data passed down to it.
                WikiSitesListSliver(
                  loading: _viewModel.sitesInitialLoading,
                  loadError: _viewModel.load.errorMessage,
                  query: _viewModel.query.trim(),
                  sites: _viewModel.filteredSites,
                  onRetry: () => _viewModel.load.execute(true),
                  onSiteTap: (site) => unawaited(_onSiteTap(site)),
                  checkingLogin: _viewModel.checkingLogin,
                ),
                if (_viewModel.filteredSites.isNotEmpty)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        AppSpacing.screenHorizontal + AppSpacing.lg,
                        AppSpacing.screenHorizontal,
                        AppSpacing.screenHorizontal + AppSpacing.lg,
                        AppSpacing.bottomNavClearance,
                      ),
                      child: Text(
                          "A wiki oldalait a szak hallgatói készítik. Az itt szereplő információ helyességéért nem vállalunk felelősséget."),
                    ),
                  )
              ],
            );
            return isIOS
                ? customScrollView
                : RefreshIndicator(
                    edgeOffset:
                        MediaQuery.paddingOf(context).top + kToolbarHeight,
                    onRefresh: () => _viewModel.load.execute(true),
                    child: customScrollView,
                  );
          }),
    );
  }
}
