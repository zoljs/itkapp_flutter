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
  final _tagsController = TextEditingController();
  List<String> tags = [];

  String _category = 'current';

  bool _loading = true;
  bool _saving = false;
  bool _hasExistingSite = false;

  @override
  void initState() {
    super.initState();
    _loadExistingSite();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _urlController.dispose();
    _tagsController.dispose();
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
        _tagsController.text = response.tags.join(', ');
        tags = response.tags;
        _category = response.category;
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
      // Catch the exception thrown if ZOD validation fails on backend
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
          TextButton(
            onPressed: () => Navigator.pop(context, true),
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
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MySiteTagsScreen(currentTags: tags),
      ),
    );

    if (result != null) {
      setState(() {
        tags = result;
      });
    }
  }

  Widget _buildForm(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const FieldLabel('Név'),
            TextFormField(
              controller: _nameController,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
              textInputAction: TextInputAction.next,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Kötelező mező' : null,
            ),
            const SizedBox(height: 18),
            const FieldLabel('URL'),
            TextFormField(
              controller: _urlController,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
              keyboardType: TextInputType.url,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                prefixText: 'https://users.itk.ppke.hu/~',
                hintText: 'naszy',
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Kötelező mező';
                final uri = Uri.tryParse('https://${v.trim()}');
                if (uri == null || !uri.isAbsolute) return 'Érvénytelen URL';
                return null;
              },
            ),
            const SizedBox(height: 18),
            const FieldLabel('Címkék'),
            Wrap(spacing: 6, runSpacing: 6, children: [
              ActionChip(
                avatar: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Új címke'),
                onPressed: () => _openTagPicker(),
              ),
              ...tags.take(3).map((tag) {
                return Chip(label: Text(tag));
              })
            ]),
            const SizedBox(height: 20),
            // const FieldLabel('Kategória'),
            // const SizedBox(height: 4),
            // SegmentedButton<String>(
            //   segments: const [
            //     ButtonSegment(value: 'og', label: Text('OG')),
            //     ButtonSegment(value: 'current', label: Text('Mostani')),
            //     ButtonSegment(value: 'wip', label: Text('WIP')),
            //   ],
            //   selected: {_category},
            //   onSelectionChanged: (selection) {
            //     setState(() => _category = selection.first);
            //   },
            // ),
            // const SizedBox(height: 28),
            SizedBox(
              height: 52,
              child: FilledButton(
                onPressed: _saving ? null : _submit,
                child: _saving
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
        actions: [
          if (_hasExistingSite)
            IconButton(
              onPressed: _delete,
              icon: const Icon(Icons.delete_outline_rounded),
            ),
        ],
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: _loading
          ? const Center(child: M3ELoadingIndicator())
          : _buildForm(context),
    );
  }
}
