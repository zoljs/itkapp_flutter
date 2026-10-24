import 'package:flutter/material.dart';
import 'package:itk_app/data/services/api_client.dart';
import 'package:itk_app/ui/admin/admin_roles_screen.dart';
import 'package:itk_app/ui/core/widgets/brand_button.dart';
import 'package:itk_app/ui/core/widgets/confirm_dialog.dart';
import 'package:itk_app/ui/core/widgets/grouped_list.dart';
import 'package:itk_app/utils/context_extensions.dart';
import 'package:itk_app/utils/open_link.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:itk_app/data/services/auth_service.dart';
import 'package:itk_app/data/services/theme_service.dart';
import 'package:itk_app/domain/models/user.dart';
import 'package:itk_app/ui/core/theme/app_fonts.dart';
import 'package:itk_app/ui/core/theme/app_spacing.dart';
import 'package:itk_app/ui/core/theme/app_themes.dart';
import 'package:itk_app/ui/core/widgets/platform_appbar.dart';
import 'package:itk_app/utils/auth_actions.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final LdapUser? _currentUser = AuthService.instance.cachedUser;
  late final Future<PackageInfo> _packageInfoFuture;

  // For now, these live in memory as they are mostly placeholders until some good ideas appear in my head.
  bool _midtermReminders = true;

  @override
  void initState() {
    super.initState();
    _packageInfoFuture = PackageInfo.fromPlatform();
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
    final LdapUser? currentUser = _currentUser;

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
                if (currentUser != null) _buildAccountGroup(currentUser),

                // Notifications
                SettingsGroup(
                  header: 'Értesítések',
                  children: [
                    SettingsTile(
                      icon: Icons.notifications_rounded,
                      iconColor: scheme.error,
                      title: 'ZH-emlékeztetők',
                      trailing: Switch.adaptive(
                        activeTrackColor: itkPrimary,
                        value: _midtermReminders,
                        onChanged: (v) => setState(() => _midtermReminders = v),
                      ),
                      onTap: () {
                        setState(() => _midtermReminders = !_midtermReminders);
                      },
                    ),
                    SettingsTile(
                      icon: Icons.schedule_rounded,
                      iconColor: scheme.error,
                      title: 'Emlékeztető ideje',
                      value: '1 nappal előtte',
                      onTap: _midtermReminders ? () {} : null,
                    ),
                  ],
                ),

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
                SettingsGroup(
                  header: 'Megjelenés',
                  footer:
                      'Az új elem hozzáadása gomb a képernyő alján jelenik meg, egy kézzel könnyebben elérhető.',
                  children: [
                    SettingsTile(
                      icon: Icons.add_rounded,
                      iconColor: scheme.tertiary,
                      title: 'Akció gombok lent',
                      onTap: () => ThemeService.instance
                          .toggleActionButtonAsFab(
                              !ThemeService.instance.actionButtonAsFab.value),
                      trailing: ValueListenableBuilder<bool>(
                        valueListenable:
                            ThemeService.instance.actionButtonAsFab,
                        builder: (context, asFab, _) => Switch.adaptive(
                          activeTrackColor: itkPrimary,
                          value: asFab,
                          onChanged:
                              ThemeService.instance.toggleActionButtonAsFab,
                        ),
                      ),
                    ),
                    SettingsTile(
                      icon: Icons.dark_mode_rounded,
                      iconColor: scheme.tertiary,
                      title: 'OLED mód',
                      onTap: () => ThemeService.instance.toggleOledMode(
                          !ThemeService.instance.oledMode.value),
                      trailing: ValueListenableBuilder<bool>(
                        valueListenable: ThemeService.instance.oledMode,
                        builder: (context, isOled, _) => Switch.adaptive(
                          activeTrackColor: itkPrimary,
                          value: isOled,
                          onChanged: ThemeService.instance.toggleOledMode,
                        ),
                      ),
                    ),
                  ],
                ),

                // Privacy
                SettingsGroup(
                  header: 'Adatok és adatvédelem',
                  children: [
                    SettingsTile(
                      icon: Icons.cleaning_services_rounded,
                      iconColor: scheme.secondary,
                      title: 'Gyorsítótár törlése',
                      onTap: () {
                        clearAllCaches();
                        context.showMessage("Gyorsítótárak törölve!");
                      },
                    ),
                    SettingsTile(
                      icon: Icons.privacy_tip_rounded,
                      iconColor: scheme.secondary,
                      title: 'Adatkezelési tájékoztató',
                      onTap: () {},
                    ),
                  ],
                ),

                // Admin
                if (_currentUser?.isAdmin ?? false)
                  SettingsGroup(
                    header: 'Adminisztrátor',
                    footer: 'Évfolyamfelelősök kinevezése és visszavonása.',
                    children: [
                      SettingsTile(
                        title: 'Jogosultságok',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AdminRolesScreen(),
                          ),
                        ),
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
                      icon: Icons.bug_report_rounded,
                      iconColor: Colors.orange,
                      title: 'Session törlése',
                      onTap: () async {
                        await ApiClient.instance.clearCookies();
                        if (!context.mounted) return;
                        context.showMessage(
                            'Cookie törölve, most frissíts valamit.');
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

                // FittedBox(
                //   fit: BoxFit.contain,
                //   child: SizedBox(
                //     width: 356,
                //     height: 412,
                //     child: Stack(
                //       children: [
                //         Positioned(
                //           left: 0,
                //           right: 0,
                //           bottom: 0,
                //           child: Center(
                //             child: Image.network(
                //                 width: 356,
                //                 'https://freepngimg.com/thumb/trampoline/132588-trampoline.png'),
                //           ),
                //         ),
                //         Center(
                //           child: Image.network(
                //               width: 167,
                //               'https://media.tenor.com/h_jy2s28rlYAAAAj/spinning-cat.gif'),
                //         ),
                //       ],
                //     ),
                //   ),
                // )
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
