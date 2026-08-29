import 'package:dio/dio.dart';
import 'package:m3e_core/m3e_core.dart';
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

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _urlController = TextEditingController();
  List<String> tags = [];

  final String _category = 'current';

  bool _loading = true;
  bool _saving = false;
  bool _hasExistingSite = false;

  static const _categories = [
    ('og', 'OG', Colors.blue),
    ('current', 'Mostani', Colors.blue),
    ('wip', 'WIP', Colors.blue),
  ];

  @override
  void initState() {
    super.initState();
    _loadExistingSite();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _loadExistingSite() async {
    final response = await _sitesService.getMySite();
    if (!mounted) return;

    setState(() {
      if (response != null) {
        _nameController.text = response.name;
        _urlController.text = response.url
            .replaceFirst(RegExp(r'^https://users.itk.ppke.hu/~'), '');
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
          url: 'https://users.itk.ppke.hu/~${_urlController.text.trim()}',
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

  Widget _buildSectionCard(BuildContext context,
      {required String title, required Widget child}) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: scheme.onSurfaceVariant,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSectionCard(
              context,
              title: 'ALAPADATOK',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const FieldLabel('Név'),
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
                  TextFormField(
                    controller: _urlController,
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface),
                    keyboardType: TextInputType.url,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      prefixText: 'https://users.itk.ppke.hu/~',
                      hintText: 'naszy',
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Kötelező mező';
                      }
                      final uri = Uri.tryParse('https://${v.trim()}');
                      if (uri == null || !uri.isAbsolute) {
                        return 'Érvénytelen URL';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            _buildSectionCard(
              context,
              title: 'CÍMKÉK',
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
          ? const Center(child: M3ELoadingIndicator())
          : _buildForm(context),
    );
  }
}
