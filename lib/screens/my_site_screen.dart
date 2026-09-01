import 'package:dio/dio.dart';
import 'package:itk_app/models/user.dart';
import 'package:itk_app/services/auth_service.dart';
import 'package:itk_app/theme/app_spacing.dart';
import 'package:itk_app/widgets/section_card.dart';
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
  final _sitesService = SitesService.instance;
  final _authService = AuthService.instance;
  LdapUser? _currentUser;

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  List<String> tags = [];

  final String _category = 'current';

  bool _loading = true;
  bool _saving = false;
  bool _hasExistingSite = false;

  static const List<Color> _colors = [
    Color(0xFF00A6E7),
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
    final user = await _authService.getSessionUser();
    if (!mounted) return;
    setState(() => _currentUser = user);
  }

  Future<void> _loadExistingSite() async {
    final response = await _sitesService.getMySite();
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
      await _sitesService.saveMySite(
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

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Profil törlése'),
        content: const Text(
          'Biztosan törlöd a saját oldaladat? Ez nem vonható vissza.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Mégse'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Törlés'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await _sitesService.deleteMySite();
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
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface),
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
                      color: Theme.of(context).colorScheme.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.warning_amber_rounded,
                            color: Theme.of(context).colorScheme.primary),
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
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
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
            SizedBox(
              height: 52,
              child: FilledButton.icon(
                onPressed: _saving ? null : _submit,
                icon: _saving
                    ? null
                    : Icon(_hasExistingSite
                        ? Icons.save_rounded
                        : Icons.add_circle_outline_rounded),
                label: _saving
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          color: Theme.of(context).colorScheme.surface,
                        ),
                      )
                    : Text(_hasExistingSite ? 'Mentés' : 'Profil létrehozása'),
              ),
            ),
            if (_hasExistingSite) ...[
              const SizedBox(height: 12),
              SizedBox(
                height: 52,
                child: OutlinedButton.icon(
                  onPressed: _delete,
                  icon: const Icon(Icons.delete_outline_rounded),
                  label: const Text('Oldal törlése'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.error,
                    side:
                        BorderSide(color: Theme.of(context).colorScheme.error),
                  ),
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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        title: Text(_hasExistingSite ? 'Saját oldalam' : 'Oldal létrehozása'),
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: _loading
          ? const Center(child: RefreshProgressIndicator())
          : _buildForm(context),
    );
  }
}
