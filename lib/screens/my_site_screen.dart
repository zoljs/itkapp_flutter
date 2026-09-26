import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:dio/dio.dart';
import 'package:itk_app/models/user.dart';
import 'package:itk_app/services/auth_service.dart';
import 'package:itk_app/theme/app_spacing.dart';
import 'package:itk_app/theme/app_themes.dart';
import 'package:itk_app/widgets/section_card.dart';
import 'package:flutter/material.dart';
import 'package:adaptive_platform_ui/adaptive_platform_ui.dart'
    show
        AdaptiveAlertDialog,
        AdaptiveAppBar,
        AdaptiveButton,
        AdaptiveButtonStyle,
        AdaptiveScaffold,
        AlertAction,
        AlertActionStyle,
        AdaptiveAppBarAction,
        SFSymbol;

import 'package:itk_app/models/user_site.dart';
import 'package:itk_app/screens/my_site_tags_screen.dart';
import 'package:itk_app/services/sites_service.dart';
import 'package:itk_app/widgets/field_label.dart';

class MySiteScreen extends StatefulWidget {
  const MySiteScreen({super.key});

  @override
  State<MySiteScreen> createState() => _MySiteScreenState();
}

class _MySiteScreenState extends State<MySiteScreen> {
  LdapUser? _currentUser;

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  List<String> tags = [];

  final String _category = 'current';

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
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentUser() async {
    final user = await AuthService.instance.getSessionUser();
    if (!mounted) return;
    setState(() => _currentUser = user);
  }

  Future<void> _loadExistingSite() async {
    final response = await SitesService.instance.getMySite();
    if (!mounted) return;

    setState(() {
      if (response != null) {
        _nameController.text = response.name;
        tags = response.tags;
        _hasExistingSite = true;
      } else {
        _hasExistingSite = false;
      }
      _loading = false;
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      await SitesService.instance.saveMySite(
        UserSite(
          name: _nameController.text.trim(),
          url: 'https://users.itk.ppke.hu/~${_currentUser?.login}',
          tags: tags,
          category: _category,
        ),
      );

      if (!mounted) return;
      setState(() {
        _hasExistingSite = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Elmentve!')),
      );
    } on DioException catch (e) {
      if (!mounted) return;

      final data = e.response?.data;
      final message = (data is Map && data['message'] != null)
          ? data['message'].toString()
          : 'Nem sikerült menteni.';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  Future<bool?> showAdaptiveConfirmDialog(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmLabel,
    String cancelLabel = 'Mégse',
    bool isDestructive = false,
  }) async {
    bool? result;

    await AdaptiveAlertDialog.show(
      context: context,
      title: title,
      message: message,
      actions: [
        AlertAction(
          title: cancelLabel,
          style: AlertActionStyle.cancel,
          onPressed: () => result = false,
        ),
        AlertAction(
          title: confirmLabel,
          style: isDestructive
              ? AlertActionStyle.destructive
              : AlertActionStyle.primary,
          onPressed: () => result = true,
        ),
      ],
    );

    return result;
  }

  Future<void> _delete() async {
    final confirmed = await showAdaptiveConfirmDialog(
      context,
      title: 'Profil törlése',
      message: 'Biztosan törlöd a saját oldaladat? Ez nem vonható vissza.',
      confirmLabel: 'Törlés',
      isDestructive: true,
    );
    if (confirmed != true) return;

    try {
      await SitesService.instance.deleteMySite();
      if (!mounted) return;
      Navigator.pop(context);
    } on DioException {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nem sikerült törölni.')),
      );
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
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;

    final scheme = Theme.of(context).colorScheme;
    final platform = Theme.of(context).platform;

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(AppSpacing.lg, isIOS ? 120 : AppSpacing.lg,
            AppSpacing.lg, AppSpacing.xxxl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SectionCard(
              title: 'Adatok',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const FieldLabel('Oldal név'),
                  TextFormField(
                    controller: _nameController,
                    style: TextStyle(color: scheme.onSurface),
                    textInputAction: TextInputAction.next,
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Kötelező mező'
                        : null,
                  ),
                  const SizedBox(height: 18),
                  const FieldLabel('URL'),
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: scheme.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.warning_amber_rounded,
                            color: scheme.primary),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'https://users.itk.ppke.hu/~${_currentUser?.login}',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                  color: scheme.onSurface,
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
            SectionCard(
                title: 'Szín',
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      ..._colors.indexed.map((record) {
                        final (index, color) = record;

                        final isSelected = index == _selectedIndex;
                        final double borderRadius = isSelected ? 12.0 : 28.0;
                        final double innerBorderRadius =
                            isSelected ? 6.0 : 20.0;

                        return AnimatedContainer(
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
                        );
                      })
                    ],
                  ),
                )),
            const SizedBox(height: 14),
            SectionCard(
              title: 'Címkék',
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ActionChip(
                    avatar: const Icon(Icons.add_rounded, size: 18),
                    label: const Text('Új címke'),
                    onPressed: _openTagPicker,
                  ),
                  ...tags.map((tag) => Chip(
                        label: Text(tag),
                        onDeleted: () => setState(() => tags.remove(tag)),
                      )),
                ],
              ),
            ),
            if (_hasExistingSite) ...[
              const SizedBox(height: 12),
              buildDeleteButton(context, _delete),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;

    return AdaptiveScaffold(
      appBar: AdaptiveAppBar(
        leading: isIOS
            ? SizedBox(
                height: 44,
                width: 44,
                child: AdaptiveButton.sfSymbol(
                  onPressed: () => Navigator.of(context).pop(),
                  sfSymbol: const SFSymbol('chevron.left', size: 20),
                  useSmoothRectangleBorder: false,
                ),
              )
            : null,
        title: _hasExistingSite ? 'Saját oldalam' : 'Oldal létrehozása',
        actions: [
          AdaptiveAppBarAction(
            onPressed: () {
              _submit;
              Navigator.pop(context);
            },
            iosSymbol: 'checkmark',
            icon: Icons.save,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: RefreshProgressIndicator())
          : _buildForm(context),
    );
  }
}

Widget buildDeleteButton(BuildContext context, VoidCallback onPressed) {
  final isIOS = Theme.of(context).platform == TargetPlatform.iOS;
  final scheme = Theme.of(context).colorScheme;

  if (isIOS) {
    return AdaptiveButton.child(
      style: AdaptiveButtonStyle.gray,
      useSmoothRectangleBorder: false,
      borderRadius: BorderRadius.circular(26),
      minSize: const Size(double.infinity, 52),
      onPressed: onPressed,
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Oldal törlése',
            style: TextStyle(
              color: CupertinoColors.destructiveRed,
            ),
          )
        ],
      ),
    );
  }

  return AdaptiveButton.child(
    style: AdaptiveButtonStyle
        .filled, // az OutlinedButton VALÓBAN tiszteletben tartja a color-t
    color: scheme.errorContainer,
    borderRadius: BorderRadius.circular(26),
    minSize: const Size(double.infinity, 52),
    onPressed: onPressed,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.delete_outline_rounded, color: scheme.error),
        const SizedBox(width: 8),
        Text('Oldal törlése', style: TextStyle(color: scheme.error)),
      ],
    ),
  );
}
