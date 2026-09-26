import 'package:dio/dio.dart';
import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:itk_app/models/user.dart';
import 'package:itk_app/services/auth_service.dart';
import 'package:itk_app/theme/app_spacing.dart';
import 'package:itk_app/theme/app_themes.dart';
import 'package:itk_app/widgets/adaptive_button.dart';
import 'package:itk_app/widgets/adaptive_icon_button.dart';
import 'package:itk_app/widgets/section_card.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:material_ui/material_ui.dart';
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
  bool _saving = false;
  bool _hasExistingSite = false;

  static const List<Color> _colors = [
    itkPrimary,
    Color(0xFF7E57C2),
    Color(0xFFEF5350),
    Color(0xFFFF9800),
    Color(0xFFFFCA28),
    Color(0xFF66BB6A),
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

    setState(() => _saving = true);

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
        _saving = false;
        _hasExistingSite = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Elmentve!')),
      );
    } on DioException catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);

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
  }) {
    final isIOS = Theme.of(context).platform == TargetPlatform.android;

    if (isIOS) {
      return showCupertinoDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 270),
            child: GlassCard(
              useOwnLayer: true,
              quality: GlassQuality.standard,
              settings: const LiquidGlassSettings(
                glassColor: Color.fromARGB(200, 26, 26, 26),
                refractiveIndex: 0.5,
                saturation: 1.5,
              ),
              padding: EdgeInsets.zero,
              shape: const LiquidRoundedSuperellipse(borderRadius: 35),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Title
                        Padding(
                          padding: const EdgeInsets.all(6.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                textAlign: TextAlign.start,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 17,
                                  color: CupertinoColors.white,
                                ),
                              ),
                              const SizedBox(height: 16),
                              // Message
                              Text(
                                message,
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: CupertinoColors.white
                                      .withValues(alpha: 0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        CupertinoButton.filled(
                          onPressed: () => Navigator.pop(context, true),
                          borderRadius: BorderRadius.circular(25),
                          minimumSize: const Size(double.infinity, 50),
                          color: CupertinoColors.activeBlue,
                          foregroundColor: CupertinoColors.white,
                          child: Text(confirmLabel),
                        ),
                        const SizedBox(height: 16),
                        CupertinoButton.filled(
                          onPressed: () => Navigator.pop(context, false),
                          borderRadius: BorderRadius.circular(25),
                          minimumSize: const Size(double.infinity, 50),
                          color: CupertinoColors.systemGrey5,
                          foregroundColor: CupertinoColors.destructiveRed,
                          child: Text(cancelLabel),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final scheme = Theme.of(context).colorScheme;
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(cancelLabel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: isDestructive
                ? FilledButton.styleFrom(backgroundColor: scheme.error)
                : null,
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
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
    final scheme = Theme.of(context).colorScheme;
    final platform = Theme.of(context).platform;

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.xxxl),
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
            const SizedBox(height: 28),
            AdaptiveButton(
              onPressed: _saving ? null : _submit,
              child: _saving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator.adaptive(),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (platform != TargetPlatform.iOS) ...[
                          Icon(_hasExistingSite
                              ? Icons.save_rounded
                              : Icons.add_circle_outline_rounded),
                          const SizedBox(width: 8),
                        ],
                        Text(
                            _hasExistingSite ? 'Mentés' : 'Profil létrehozása'),
                      ],
                    ),
            ),
            if (_hasExistingSite) ...[
              const SizedBox(height: 12),
              AdaptiveButton(
                variant: AdaptiveButtonVariant.destructive,
                onPressed: _delete,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (platform != TargetPlatform.iOS) ...[
                      const Icon(Icons.delete_outline_rounded),
                      const SizedBox(width: 8),
                    ],
                    const Text('Oldal törlése'),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: scheme.surface,
        elevation: 0,
        foregroundColor: scheme.onSurface,
        leading: Navigator.canPop(context)
            ? Padding(
                padding: const EdgeInsets.fromLTRB(AppSpacing.screenHorizontal,
                    AppSpacing.xs, AppSpacing.xs, AppSpacing.xs),
                child: AdaptiveIconButton(
                  icon: Icons.arrow_back,
                  onPressed: () => Navigator.pop(context),
                ),
              )
            : null,
        title: Text(_hasExistingSite ? 'Saját oldalam' : 'Oldal létrehozása'),
      ),
      backgroundColor: scheme.surface,
      body: _loading
          ? const Center(child: RefreshProgressIndicator())
          : _buildForm(context),
    );
  }
}
