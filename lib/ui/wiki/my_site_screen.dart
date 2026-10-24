import 'package:flutter/material.dart';
import 'package:itk_app/data/services/auth_service.dart';
import 'package:itk_app/data/services/sites_service.dart';
import 'package:itk_app/domain/models/user.dart';
import 'package:itk_app/domain/models/user_site.dart';
import 'package:itk_app/ui/core/theme/app_spacing.dart';
import 'package:itk_app/ui/core/widgets/adaptive_sheet.dart';
import 'package:itk_app/ui/core/widgets/brand_button.dart';
import 'package:itk_app/ui/core/widgets/confirm_dialog.dart';
import 'package:itk_app/ui/core/widgets/grouped_list.dart';
import 'package:itk_app/ui/core/widgets/brand_appbar.dart';
import 'package:itk_app/ui/wiki/my_site_tags_screen.dart';
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
  bool isPublic = true;
  bool isPhpEnabled = false;

  bool _loading = true;
  bool _hasExistingSite = false;

  // static const List<Color> _colors = [
  //   itkPrimary,
  //   Color(0xFF7E57C2),
  //   Color(0xFFEF5350),
  //   Color(0xFFFF9800),
  //   Color(0xFFFFCA28),
  //   Color(0xFF66BB6A),
  //   Color.fromARGB(255, 202, 225, 203),
  // ];
  // int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    _loadExistingSite();
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
      case Ok(value: final UserSite site):
        setState(() {
          tags = List.of(site.tags);
          _hasExistingSite = true;
          isPublic = site.isPublic;
          isPhpEnabled = site.isPhpEnabled;
          _loading = false;
        });
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

    final result =
        await SitesService.instance.saveMySite(tags, isPublic, isPhpEnabled);
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
    await showAdaptiveSheet<void>(
      context: context,
      builder: (context, controller) => MySiteTagsScreen(
        scrollController: controller,
        currentTags: tags,
        onSave: (result) => setState(() => tags = result),
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg + MediaQuery.paddingOf(context).top + kToolbarHeight,
        AppSpacing.lg,
        AppSpacing.xxxl,
      ),
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
                value: _currentUser?.login ?? '',
              ),
            ],
          ),
          // SettingsGroup(
          //   header: 'Megjelenés',
          //   children: [
          //     Padding(
          //       padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          //       child: SingleChildScrollView(
          //         scrollDirection: Axis.horizontal,
          //         padding:
          //             const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          //         child: Row(
          //           children: _colors.indexed.map((record) {
          //             final (index, color) = record;
          //             final isSelected = index == _selectedIndex;
          //             final double borderRadius = isSelected ? 12.0 : 28.0;
          //             final double innerBorderRadius = isSelected ? 6.0 : 20.0;

          //             return Padding(
          //               padding: const EdgeInsets.only(right: 8.0),
          //               child: AnimatedContainer(
          //                 curve: Curves.easeInOutCubic,
          //                 duration: const Duration(milliseconds: 300),
          //                 height: 56,
          //                 width: 56,
          //                 alignment: Alignment.center,
          //                 decoration: BoxDecoration(
          //                   borderRadius: BorderRadius.circular(borderRadius),
          //                   border: Border.all(
          //                     color: isSelected ? color : Colors.transparent,
          //                     width: 4,
          //                   ),
          //                 ),
          //                 child: AnimatedContainer(
          //                   curve: Curves.easeInOutCubic,
          //                   duration: const Duration(milliseconds: 300),
          //                   height: 40,
          //                   width: 40,
          //                   decoration: BoxDecoration(
          //                     gradient: LinearGradient(
          //                       begin: Alignment.topLeft,
          //                       end: Alignment.bottomRight,
          //                       colors: [
          //                         color,
          //                         Color.lerp(color, Colors.black, 0.4)!,
          //                       ],
          //                     ),
          //                     borderRadius:
          //                         BorderRadius.circular(innerBorderRadius),
          //                   ),
          //                   child: GestureDetector(
          //                     onTap: () =>
          //                         setState(() => _selectedIndex = index),
          //                   ),
          //                 ),
          //               ),
          //             );
          //           }).toList(),
          //         ),
          //       ),
          //     ),
          //   ],
          // ),
          SettingsGroup(
              header: 'Beállítások',
              footer:
                  'Bekapcsolásával ki lesz listázva a Users oldalad tartalma az alkalmazásban.',
              children: [
                SettingsTile(
                  title: 'Oldal publikussá tétele',
                  trailing: Switch.adaptive(
                    value: isPublic,
                    onChanged: (value) => setState(() => isPublic = value),
                  ),
                  onTap: () => setState(() => isPublic = !isPublic),
                ),
                SettingsTile(
                  title: 'PHP Fájlkezelő engedélyezése',
                  trailing: Switch.adaptive(
                    value: isPhpEnabled,
                    //onChanged: (value) => setState(() => isPhpEnabled = value),
                    onChanged: null,
                  ),
                  //onTap: () => setState(() => isPhpEnabled = !isPhpEnabled),
                ),
              ]),

          SettingsGroup(
            header: 'Címkék',
            footer: 'A címkék alapján a kereső is listázza az oldalakat.'
                '\nBalra húzva törölheted a címkét.',
            children: [
              SettingsTile(
                title: 'Új címke hozzáadása',
                onTap: _openTagPicker,
              ),
              ...tags.map((tag) {
                return buildTagRow(tag);
              }),
            ],
          ),
          if (_hasExistingSite) ...[
            BrandButton(
              onTap: _delete,
              height: 52,
              backgroundColor: scheme.errorContainer,
              child: Center(
                child: Text(
                  'Oldal törlése',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: scheme.error,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
          ],
        ],
      ),
    );
  }

  Dismissible buildTagRow(String tag) {
    final scheme = Theme.of(context).colorScheme;

    return Dismissible(
      key: ValueKey(tag.hashCode),
      direction: DismissDirection.endToStart,
      background: Container(
        color: scheme.error,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: Icon(Icons.delete_rounded, color: scheme.onError),
      ),
      child: Container(
        color: scheme.surfaceContainerHigh,
        child: SettingsTile(
          title: tag,
        ),
      ),
      onDismissed: (_) => setState(() {
        tags.remove(tag);
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: buildBrandAppBar(
        context: context,
        title: _hasExistingSite ? 'Saját oldalam' : 'Oldal létrehozása',
        onAction: () async {
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
