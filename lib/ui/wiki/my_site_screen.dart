import 'package:flutter/material.dart';
import 'package:itk_app/data/repositories/auth_repository.dart';
import 'package:itk_app/data/repositories/sites_repository.dart';
import 'package:itk_app/ui/core/theme/app_spacing.dart';
import 'package:itk_app/ui/core/widgets/adaptive_sheet.dart';
import 'package:itk_app/ui/core/widgets/brand_button.dart';
import 'package:itk_app/ui/core/widgets/confirm_dialog.dart';
import 'package:itk_app/ui/core/widgets/grouped_list.dart';
import 'package:itk_app/ui/core/widgets/brand_appbar.dart';
import 'package:itk_app/ui/core/screens/subject_multi_picker_screen.dart';
import 'package:itk_app/ui/wiki/viewmodels/my_site_viewmodel.dart';
import 'package:itk_app/utils/context_extensions.dart';
import 'package:provider/provider.dart';

class MySiteScreen extends StatefulWidget {
  const MySiteScreen({super.key});

  @override
  State<MySiteScreen> createState() => _MySiteScreenState();
}

class _MySiteScreenState extends State<MySiteScreen> {
  late final MySiteViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = MySiteViewModel(
      sitesRepository: context.read<SitesRepository>(),
      authRepository: context.read<AuthRepository>(),
    );
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

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

  Future<void> _submit() async {
    await _viewModel.save.execute();
    if (!mounted) return;

    if (_viewModel.save.completed) {
      context.showMessage('Elmentve!');
    } else if (_viewModel.save.errorMessage case final message?) {
      context.showMessage(message);
    }
  }

  Future<void> _deleteSite() async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Profil törlése',
      message: 'Biztosan törlöd a saját oldaladat? Ez nem vonható vissza.',
      confirmLabel: 'Törlés',
      isDestructive: true,
    );
    if (confirmed != true) return;

    await _viewModel.delete.execute();
    if (!mounted) return;

    if (_viewModel.delete.completed) {
      context.showMessage('Saját oldalad törölve lett.');
      Navigator.pop(context);
    } else if (_viewModel.delete.errorMessage case final message?) {
      context.showMessage(message);
    }
  }

  Future<void> _openTagPicker() async {
    await showAdaptiveSheet<void>(
      context: context,
      builder: (context, controller) => SubjectMultiPickerScreen(
        scrollController: controller,
        currentTags: _viewModel.tags,
        onSave: (result) => _viewModel.setTags(result),
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
            footer: 'Az oldal neve és az URL a bejelentkezett fiókodhoz van rögzítve, nem módosítható.',
            children: [
              SettingsTile(
                title: 'Név és URL',
                value: _viewModel.login ?? '',
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
          SettingsGroup(header: 'Beállítások', footer: 'Bekapcsolásával ki lesz listázva a Users oldalad tartalma az alkalmazásban.', children: [
            SettingsTile(
              title: 'Oldal publikussá tétele',
              trailing: Switch.adaptive(
                value: _viewModel.isPublic,
                onChanged: (value) => _viewModel.setPublic(value),
              ),
              onTap: () => _viewModel.setPublic(!_viewModel.isPublic),
            ),
            SettingsTile(
              title: 'PHP Fájlkezelő engedélyezése',
              trailing: Switch.adaptive(
                value: _viewModel.isPhpEnabled,
                onChanged: (value) => _viewModel.setPhpEnabled(value),
              ),
              onTap: () => _viewModel.setPhpEnabled(!_viewModel.isPhpEnabled),
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
              ..._viewModel.tags.map((tag) {
                return _buildTagRow(tag);
              }),
            ],
          ),
          if (_viewModel.hasExistingSite) ...[
            BrandButton(
              onTap: _deleteSite,
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

  Dismissible _buildTagRow(String tag) {
    final scheme = Theme.of(context).colorScheme;

    return Dismissible(
      key: ValueKey(tag),
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
      confirmDismiss: (_) async =>
          await showConfirmDialog(
            context,
            title: 'Címke törlése',
            message: 'Biztosan törlöd a "$tag" címkét?',
            confirmLabel: 'Törlés',
            isDestructive: true,
          ) ==
          true,
      onDismissed: (_) {
        _viewModel.setTags(_viewModel.tags.where((t) => t != tag).toList());
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
        listenable: Listenable.merge([_viewModel, _viewModel.load]),
        builder: (context, _) {
          return Scaffold(
            extendBodyBehindAppBar: true,
            appBar: buildBrandAppBar(
              context: context,
              title: _viewModel.hasExistingSite ? 'Saját oldalam' : 'Oldal létrehozása',
              onAction: () async {
                await _submit();
                if (!context.mounted) return;
                if (_viewModel.save.completed) Navigator.pop(context);
              },
            ),
            body: _viewModel.load.running ? const Center(child: RefreshProgressIndicator()) : _buildForm(context),
          );
        });
  }
}
