import 'package:itk_app/domain/models/user.dart';
import 'package:itk_app/data/services/auth_service.dart';
import 'package:itk_app/ui/core/theme/app_spacing.dart';
import 'package:itk_app/ui/core/theme/app_themes.dart';
import 'package:itk_app/ui/core/widgets/ack_appbar.dart';
import 'package:itk_app/ui/core/widgets/brand_button.dart';
import 'package:itk_app/ui/core/widgets/confirm_dialog.dart';
import 'package:itk_app/ui/core/widgets/grouped_list.dart';
import 'package:flutter/material.dart';

import 'package:itk_app/domain/models/user_site.dart';
import 'package:itk_app/ui/wiki/my_site_tags_screen.dart';
import 'package:itk_app/data/services/sites_service.dart';
import 'package:itk_app/utils/context_extensions.dart';
import 'package:itk_app/utils/result.dart';

class MySiteScreen extends StatefulWidget {
  const MySiteScreen({super.key});

  @override
  State<MySiteScreen> createState() => _MySiteScreenState();
}

class _MySiteScreenState extends State<MySiteScreen> {
  LdapUser? _currentUser;

  List<String> tags = [];

  bool _loading = true;
  bool _hasExistingSite = false;

  static const List<Color> _colors = [
    itkPrimary,
    Color(0xFF7E57C2),
    Color(0xFFEF5350),
    Color(0xFFFF9800),
    Color(0xFFFFCA28),
    Color(0xFF66BB6A),
    Color.fromARGB(255, 202, 225, 203),
  ];
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    _loadExistingSite();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadCurrentUser() async {
    final user = await AuthService.instance.getSessionUser();
    if (!mounted) return;
    setState(() => _currentUser = user);
  }

  Future<void> _loadExistingSite() async {
    final result = await SitesService.instance.getMySite();
    if (!mounted) return;

    switch (result) {
      // Own site exists
      case Ok(value: final UserSite site):
        setState(() {
          tags = List.of(site.tags);
          _hasExistingSite = true;
          _loading = false;
        });
      // No own site yet
      case Ok(value: null):
        setState(() {
          _hasExistingSite = false;
          _loading = false;
        });
      case Err(:final message):
        setState(() => _loading = false);
        context.showMessage(message);
    }
  }

  Future<void> _submit() async {
    final user = _currentUser;
    if (user == null) return;

    final result = await SitesService.instance.saveMySite(tags);
    if (!mounted) return;

    switch (result) {
      case Ok():
        setState(() => _hasExistingSite = true);
        context.showMessage('Elmentve!');

      case Err(:final message):
        context.showMessage(message);
    }
  }

  Future<void> _delete() async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Profil törlése',
      message: 'Biztosan törlöd a saját oldaladat? Ez nem vonható vissza.',
      confirmLabel: 'Törlés',
      isDestructive: true,
    );
    if (confirmed != true) return;

    final result = await SitesService.instance.deleteMySite();
    if (!mounted) return;

    switch (result) {
      case Ok():
        Navigator.pop(context);
      case Err(:final message):
        context.showMessage(message);
    }
  }

  Future<void> _openTagPicker() async {
    final result = await Navigator.push<List<String>>(
      context,
      MaterialPageRoute(
        builder: (_) => MySiteTagsScreen(currentTags: tags),
      ),
    );

    if (result != null) {
      setState(() => tags = result);
    }
  }

  Widget _buildForm(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.lg + MediaQuery.paddingOf(context).top + kToolbarHeight,
          AppSpacing.lg,
          AppSpacing.xxxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SettingsGroup(
            header: 'Adatok',
            footer:
                'Az oldal neve és az URL a bejelentkezett fiókodhoz van rögzítve, nem módosítható.',
            children: [
              SettingsTile(
                title: 'Név és URL',
                value: _currentUser?.login ?? "",
              ),
            ],
          ),

          // Szín
          SettingsGroup(
            header: 'Megjelenés',
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  child: Row(
                    children: _colors.indexed.map((record) {
                      final (index, color) = record;
                      final isSelected = index == _selectedIndex;
                      final double borderRadius = isSelected ? 12.0 : 28.0;
                      final double innerBorderRadius = isSelected ? 6.0 : 20.0;

                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: AnimatedContainer(
                          curve: Curves.easeInOutCubic,
                          duration: const Duration(milliseconds: 300),
                          height: 56,
                          width: 56,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(borderRadius),
                              border: Border.all(
                                color: isSelected ? color : Colors.transparent,
                                width: 4,
                              )),
                          child: AnimatedContainer(
                            curve: Curves.easeInOutCubic,
                            duration: const Duration(milliseconds: 300),
                            height: 40,
                            width: 40,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  color,
                                  Color.lerp(color, Colors.black, 0.4)!,
                                ],
                              ),
                              borderRadius:
                                  BorderRadius.circular(innerBorderRadius),
                            ),
                            child: GestureDetector(
                              onTap: () =>
                                  setState(() => _selectedIndex = index),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),

          // Címkék
          SettingsGroup(
            header: 'Címkék',
            children: [
              SettingsTile(
                title: 'Új címke hozzáadása',
                onTap: _openTagPicker,
              ),
              if (tags.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.lg,
                      AppSpacing.xs, AppSpacing.lg, AppSpacing.lg),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: tags.map((tag) {
                      return Chip(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        label: Text(tag),
                        labelStyle:
                            TextStyle(color: scheme.onSecondaryContainer),
                        backgroundColor: scheme.secondaryContainer,
                        shape: const StadiumBorder(),
                        side: BorderSide.none,
                        deleteIcon: const Icon(Icons.close_rounded, size: 16),
                        deleteIconColor: scheme.onSecondaryContainer,
                        onDeleted: () =>
                            setState(() => tags = [...tags]..remove(tag)),
                      );
                    }).toList(),
                  ),
                ),
              ]
            ],
          ),

          // Törlés
          if (_hasExistingSite) ...[
            BrandButton(
              onTap: _delete,
              height: 52,
              backgroundColor: scheme.errorContainer,
              child: Center(
                  child: Text(
                "Oldal törlése",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: scheme.error,
                ),
              )),
            ),
            const SizedBox(
              height: AppSpacing.xxl,
            )
          ]
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: buildAckAppBar(
        context: context,
        scheme: scheme,
        title: Text(_hasExistingSite ? 'Saját oldalam' : 'Oldal létrehozása'),
        onPressed: () async {
          await _submit();
          if (!context.mounted) return;
          Navigator.pop(context);
        },
      ),
      body: _loading
          ? const Center(child: RefreshProgressIndicator())
          : _buildForm(context),
    );
  }
}
