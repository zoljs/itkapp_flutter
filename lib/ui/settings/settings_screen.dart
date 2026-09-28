import 'package:itk_app/domain/models/user.dart';
import 'package:itk_app/ui/wiki/my_site_screen.dart';
import 'package:itk_app/data/services/auth_service.dart';
import 'package:itk_app/data/services/sites_service.dart';
import 'package:itk_app/data/services/theme_service.dart';
import 'package:itk_app/ui/core/theme/app_fonts.dart';
import 'package:itk_app/ui/core/theme/app_radius.dart';
import 'package:itk_app/ui/core/theme/app_spacing.dart';
import 'package:itk_app/ui/core/theme/app_themes.dart';
import 'package:itk_app/utils/auth_actions.dart';
import 'package:itk_app/ui/core/widgets/adaptive_pressable.dart';

import 'package:itk_app/ui/core/widgets/my_site_card.dart';
import 'package:itk_app/ui/core/widgets/section_card.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:itk_app/ui/core/widgets/platform_appbar.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final LdapUser? _currentUser = AuthService.instance.cachedUser;

  // Conversion to Futures for easier management
  late final Future<PackageInfo> _packageInfoFuture;

  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _packageInfoFuture = PackageInfo.fromPlatform();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _openMySite() async {
    await Navigator.push(
        context, MaterialPageRoute(builder: (context) => const MySiteScreen()));
  }

  Future<void> _reportBug() async {
    final uri = Uri.parse(
      'https://github.com/BWW01/itkAPP_main/issues/new'
      '?title=${Uri.encodeComponent('[App] ')}'
      '&labels=${Uri.encodeComponent('bug,mobile-app')}',
    );

    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;

    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
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
                    child: Text(
                      '${_currentUser?.login[0].toUpperCase()}',
                      style: const TextStyle(
                          fontSize: 28, fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.screenHorizontal,
                    AppSpacing.screenHorizontal,
                    AppSpacing.screenHorizontal,
                    AppSpacing.bottomNavClearance),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Profile section
                      SectionCard(
                        title: 'Profil',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(
                                  AppSpacing.screenHorizontal),
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .surfaceContainerHigh,
                                borderRadius:
                                    BorderRadius.circular(AppRadius.xl),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.warning_amber_rounded,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${_currentUser?.login}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 14,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurface,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Ez a bejelentkezett fiókodhoz van rögzítve, nem módosítható.',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurfaceVariant,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),

                      // WIKI Page section
                      SectionCard(
                        title: 'WIKI Oldal',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            ValueListenableBuilder(
                              valueListenable:
                                  SitesService.instance.mySiteNotifier,
                              builder: (context, mySite, _) {
                                return MySiteCard(
                                  mySite: mySite,
                                  openMySite: _openMySite,
                                );
                              },
                            )
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),

                      // App Display section
                      SectionCard(
                        title: 'Megjelenés',
                        child: Column(
                          children: [
                            Material(
                              color: Colors.transparent,
                              child: ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: Icon(
                                  Icons.dark_mode,
                                  color: scheme.primary,
                                ),
                                title: const Text(
                                  'OLED mód',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14),
                                ),
                                subtitle: const Text(
                                  'Magától értetődő, nem?',
                                  style: TextStyle(fontSize: 12),
                                ),
                                trailing: Switch.adaptive(
                                  activeTrackColor: itkPrimary,
                                  value: ThemeService.instance.oledMode.value,
                                  onChanged: (bool value) {
                                    ThemeService.instance.toggleOledMode(value);
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(
                        height: 14,
                      ),

                      // App Info section
                      SectionCard(
                        title: 'App infó',
                        child: Column(
                          children: [
                            Material(
                              color: Colors.transparent,
                              child: ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: Icon(
                                  Icons.bug_report_outlined,
                                  color: scheme.primary,
                                ),
                                title: const Text(
                                  'Hiba bejelentése',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14),
                                ),
                                subtitle: const Text(
                                  'Megnyitja a GitHub issue oldalt',
                                  style: TextStyle(fontSize: 12),
                                ),
                                trailing: const Icon(Icons.open_in_new_rounded,
                                    size: 18),
                                onTap: _reportBug,
                              ),
                            ),
                            const Divider(height: 1),
                            FutureBuilder<PackageInfo>(
                              future: _packageInfoFuture,
                              builder: ((context, snapshot) {
                                final String subtitle =
                                    switch (snapshot.connectionState) {
                                  ConnectionState.waiting => 'Betöltés...',
                                  _ when snapshot.hasError =>
                                    'Ismeretlen verzió',
                                  _ =>
                                    'v${snapshot.data!.version} (${snapshot.data!.buildNumber})',
                                };

                                return ListTile(
                                  enabled: true,
                                  enableFeedback: true,
                                  contentPadding: EdgeInsets.zero,
                                  leading: Icon(Icons.info_outline_rounded,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary),
                                  title: const Text('Verzió',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14)),
                                  subtitle: Text(subtitle,
                                      style: const TextStyle(fontSize: 12)),
                                );
                              }),
                            )
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: AdaptivePressable(
                          onTap: () => performLogout(context),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (!isIOS) ...[
                                Icon(Icons.logout_rounded,
                                    size: 18, color: scheme.errorContainer),
                                const SizedBox(width: 6),
                              ],
                              Text('Kijelentkezés',
                                  style:
                                      TextStyle(color: scheme.errorContainer)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
