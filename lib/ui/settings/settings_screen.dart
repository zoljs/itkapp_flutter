import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:itk_app/data/repositories/auth_repository.dart';
import 'package:itk_app/data/repositories/calendar_repository.dart';
import 'package:itk_app/data/repositories/midterms_repository.dart';
import 'package:itk_app/data/repositories/onboarding_repository.dart';
import 'package:itk_app/data/repositories/sites_repository.dart';
import 'package:itk_app/data/repositories/subjects_repository.dart';
import 'package:itk_app/data/repositories/theme_repository.dart';
import 'package:itk_app/data/services/api_client.dart';
import 'package:itk_app/routing/routes.dart';
import 'package:itk_app/ui/core/widgets/brand_button.dart';
import 'package:itk_app/ui/core/widgets/confirm_dialog.dart';
import 'package:itk_app/ui/core/widgets/grouped_list.dart';
import 'package:itk_app/ui/settings/viewmodels/settings_viewmodel.dart';
import 'package:itk_app/utils/context_extensions.dart';
import 'package:itk_app/utils/open_link.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:itk_app/domain/models/user.dart';
import 'package:itk_app/ui/core/theme/app_fonts.dart';
import 'package:itk_app/ui/core/theme/app_spacing.dart';
import 'package:itk_app/ui/core/theme/app_themes.dart';
import 'package:itk_app/ui/core/widgets/platform_appbar.dart';
import 'package:itk_app/utils/auth_actions.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final SettingsViewModel _viewModel;
  late final Future<PackageInfo> _packageInfoFuture;

  @override
  void initState() {
    super.initState();
    _packageInfoFuture = PackageInfo.fromPlatform();
    _viewModel = SettingsViewModel(
      authRepository: context.read<AuthRepository>(),
      themeRepository: context.read<ThemeRepository>(),
      subjectsRepository: context.read<SubjectsRepository>(),
      sitesRepository: context.read<SitesRepository>(),
      calendarRepository: context.read<CalendarRepository>(),
      midtermsRepository: context.read<MidtermsRepository>(),
      apiClient: context.read<ApiClient>(),
      onboardingRepository: context.read<OnboardingRepository>(),
    );
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _reportBug() => openLink(context,
      'https://github.com/zoljs/itkapp_flutter/issues/new?title=${Uri.encodeComponent('[App] ')}&labels=${Uri.encodeComponent('bug,mobile-app')}');

  Future<void> _confirmLogout() async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Kijelentkezel?',
      message:
          'A naptárad és a beállításaid újra bejelentkezés után érhetők el.',
      confirmLabel: 'Kijelentkezés',
      isDestructive: true,
    );
    if (confirmed == true && mounted) performLogout(context);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          ShrinkingSliverAppBar(
            flexibleSpaceBarTitle: Text(
              'Beállítások',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.merge(topBarTitleStyle),
            ),
            centeredWidget: CircleAvatar(
              backgroundColor: scheme.surface,
              radius: 55,
              child: CircleAvatar(
                backgroundColor: scheme.primary,
                radius: 45,
                child: const Text(
                  'XD',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenHorizontal,
              AppSpacing.lg,
              AppSpacing.screenHorizontal,
              AppSpacing.bottomNavClearance,
            ),
            sliver: SliverList.list(
              children: [
                // Account
                if (_viewModel.currentUser != null)
                  _buildAccountGroup(_viewModel.currentUser!),

                // Calendar
                SettingsGroup(
                  header: 'Naptár',
                  children: [
                    SettingsTile(
                      icon: Icons.view_day_rounded,
                      iconColor: scheme.primary,
                      title: 'Alapnézet',
                      value: 'Nap',
                      onTap: () {},
                    ),
                    SettingsTile(
                      icon: Icons.link_rounded,
                      iconColor: scheme.primary,
                      title: 'Naptárlinkek',
                      onTap: () {},
                    ),
                  ],
                ),

                // Display
                ListenableBuilder(
                    listenable: Listenable.merge([_viewModel]),
                    builder: (context, _) {
                      return SettingsGroup(
                        header: 'Megjelenés',
                        footer:
                            'Az új elem hozzáadása gomb a képernyő alján jelenik meg, egy kézzel könnyebben elérhető.',
                        children: [
                          SettingsTile(
                            icon: Icons.add_rounded,
                            iconColor: scheme.tertiary,
                            title: 'Akció gombok lent',
                            onTap: () => _viewModel.toggleActionButtonAsFab(
                                !_viewModel.isActionButtonAsFab),
                            trailing: Switch.adaptive(
                              activeTrackColor: itkPrimary,
                              value: _viewModel.isActionButtonAsFab,
                              onChanged: (value) =>
                                  _viewModel.toggleActionButtonAsFab(
                                      !_viewModel.isActionButtonAsFab),
                            ),
                          ),
                          SettingsTile(
                            icon: Icons.dark_mode_rounded,
                            iconColor: scheme.tertiary,
                            title: 'OLED mód',
                            onTap: () => _viewModel
                                .toggleOledMode(!_viewModel.isOledMode),
                            trailing: Switch.adaptive(
                              activeTrackColor: itkPrimary,
                              value: _viewModel.isOledMode,
                              onChanged: (value) => _viewModel
                                  .toggleOledMode(!_viewModel.isOledMode),
                            ),
                          ),
                        ],
                      );
                    }),

                // Admin
                if (_viewModel.currentUser?.isAdmin ?? false)
                  SettingsGroup(
                    header: 'Adminisztrátor',
                    footer: 'Évfolyamfelelősök kinevezése és visszavonása.',
                    children: [
                      SettingsTile(
                        icon: Icons.shield_rounded,
                        iconColor: Colors.lightBlue,
                        title: 'Jogosultságok',
                        onTap: () {
                          context.push(Routes.adminRoles);
                        },
                      ),
                    ],
                  ),

                // App info
                SettingsGroup(
                  header: 'Névjegy',
                  children: [
                    FutureBuilder<PackageInfo>(
                      future: _packageInfoFuture,
                      builder: (context, snapshot) => SettingsTile(
                        icon: Icons.info_rounded,
                        iconColor: scheme.outline,
                        title: 'Verzió',
                        value: switch (snapshot.connectionState) {
                          ConnectionState.done when snapshot.hasData =>
                            '${snapshot.data!.version} (${snapshot.data!.buildNumber})',
                          ConnectionState.done => 'Ismeretlen',
                          _ => '…',
                        },
                      ),
                    ),
                    SettingsTile(
                      icon: Icons.privacy_tip_rounded,
                      iconColor: scheme.outline,
                      title: 'Adatkezelési tájékoztató',
                      onTap: () {},
                    ),
                    SettingsTile(
                      icon: Icons.description_rounded,
                      iconColor: scheme.outline,
                      title: 'Nyílt forráskódú licencek',
                      onTap: () {
                        showLicensePage(
                          context: context,
                          applicationName: "",
                          applicationIcon: Image.asset(
                            'assets/icons/itkapp-small.png',
                            height: 72,
                            errorBuilder: (_, __, ___) => Icon(
                              Icons.school_outlined,
                              size: 64,
                              color: scheme.onSurface,
                            ),
                          ),
                        );
                      },
                    ),
                    SettingsTile(
                      icon: Icons.bug_report_rounded,
                      iconColor: scheme.outline,
                      title: 'Hiba bejelentése',
                      external: true,
                      onTap: _reportBug,
                    ),
                  ],
                ),

                // if (kDebugMode)
                SettingsGroup(
                  header: 'Debug',
                  children: [
                    SettingsTile(
                      icon: Icons.cleaning_services_rounded,
                      iconColor: Colors.orange,
                      title: 'Gyorsítótár törlése',
                      onTap: () {
                        _viewModel.clearCaches();
                        context.showMessage("Gyorsítótárak törölve!");
                      },
                    ),
                    SettingsTile(
                      icon: Icons.bug_report_rounded,
                      iconColor: Colors.orange,
                      title: 'Munkamenet törlése',
                      onTap: () async {
                        await _viewModel.clearCookies();
                        if (!context.mounted) return;
                        context.showMessage(
                            'Cookie törölve, most frissíts valamit.');
                      },
                    ),
                    SettingsTile(
                      icon: Icons.bug_report_rounded,
                      iconColor: Colors.orange,
                      title: 'Onboarding visszaállítása',
                      onTap: () async {
                        await _viewModel.resetOnboarding();
                        if (!context.mounted) return;
                        context.showMessage('Onboarding visszaállítva.');
                      },
                    ),
                  ],
                ),

                // Logout

                BrandButton(
                  onTap: _confirmLogout,
                  height: 52,
                  backgroundColor: scheme.errorContainer,
                  child: Center(
                      child: Text(
                    "Kijelentkezés",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: scheme.error,
                    ),
                  )),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountGroup(LdapUser currentUser) {
    return SettingsGroup(
      header: 'Fiók',
      footer:
          'A felhasználónév a bejelentkezett fiókodhoz tartozik, nem módosítható.',
      children: [
        SettingsTile(
          title: 'Név',
          value: currentUser.name,
        ),
        SettingsTile(
          title: 'Email',
          value: currentUser.email,
        ),
        SettingsTile(
          title: 'Shibboleth azonosító',
          value: currentUser.login,
        ),
        SettingsTile(
          title: 'Évfolyamfelelős',
          value: currentUser.canModerateMidterms ? 'Igen' : 'Nem',
        ),
        SettingsTile(
          title: 'Admin',
          value: currentUser.isAdmin ? 'Igen' : 'Nem',
        ),
      ],
    );
  }
}
