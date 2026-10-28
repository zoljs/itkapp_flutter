import 'package:flutter/material.dart';
import 'package:itk_app/data/repositories/calendar_repository.dart';
import 'package:itk_app/ui/calendar/viewmodels/calendar_links_viewmodel.dart';
import 'package:itk_app/ui/core/theme/app_spacing.dart';
import 'package:itk_app/ui/core/widgets/brand_appbar.dart';
import 'package:itk_app/ui/core/widgets/grouped_list.dart';
import 'package:itk_app/utils/context_extensions.dart';
import 'package:provider/provider.dart';

class CalendarLinksScreen extends StatefulWidget {
  const CalendarLinksScreen({super.key});

  @override
  State<CalendarLinksScreen> createState() => _CalendarLinksScreenState();
}

class _CalendarLinksScreenState extends State<CalendarLinksScreen> {
  late final CalendarLinksViewmodel _viewModel;
  final _neptunController = TextEditingController();
  final _moodleController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _viewModel = CalendarLinksViewmodel(repository: context.read<CalendarRepository>());
    _viewModel.load.addListener(_fillFields);
  }

  @override
  void dispose() {
    _viewModel.dispose();
    _neptunController.dispose();
    _moodleController.dispose();
    super.dispose();
  }

  void _fillFields() {
    if (!_viewModel.load.completed) return;
    _neptunController.text = _viewModel.neptunUrl;
    _moodleController.text = _viewModel.moodleUrl;
  }

  Future<void> _save() async {
    await _viewModel.save.execute();
    if (!mounted) return;
    final error = _viewModel.save.errorMessage;
    context.showMessage(error ?? 'Naptárlinkek elmentve!');
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final muted = TextStyle(fontSize: 13, color: scheme.onSurfaceVariant);

    return ListenableBuilder(
        listenable: Listenable.merge([_viewModel, _viewModel.load, _viewModel.save]),
        builder: (context, _) {
          return Scaffold(
            appBar: buildBrandAppBar(
              context: context,
              title: 'Naptárlinkek',
              onAction: _viewModel.canSave ? _save : null,
            ),
            body: ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenHorizontal,
                AppSpacing.lg,
                AppSpacing.screenHorizontal,
                AppSpacing.xxxxl,
              ),
              children: [
                Text(
                  'Add meg a naptáraid linkjét, és az órarended, határidőid '
                  'egy helyen jelennek meg az appban.',
                  style: muted,
                ),
                const SizedBox(height: AppSpacing.xl),

                // Fixed sources
                _FixedLinkGroup(
                  controller: _neptunController,
                  onChanged: _viewModel.setNeptunUrl,
                  title: 'Neptun',
                  icon: Icons.school_rounded,
                  iconColor: scheme.primary,
                  hint: 'https://…/neptun.ics',
                  lastSynced: 'Utoljára szinkronizálva: ma 08:02',
                  helpTitle: 'Hol találom a Neptun naptárlinkemet?',
                ),
                _FixedLinkGroup(
                  controller: _moodleController,
                  onChanged: _viewModel.setMoodleUrl,
                  title: 'Moodle',
                  icon: Icons.assignment_rounded,
                  iconColor: scheme.tertiary,
                  hint: 'https://…/moodle.ics',
                  lastSynced: 'Még nincs összekapcsolva',
                  helpTitle: 'Hol találom a Moodle naptárlinkemet?',
                ),
              ],
            ),
          );
        });
  }
}

class _FixedLinkGroup extends StatelessWidget {
  const _FixedLinkGroup({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.hint,
    required this.lastSynced,
    required this.helpTitle,
    required this.controller,
    required this.onChanged,
  });

  final String title;
  final IconData icon;
  final Color iconColor;
  final String hint;
  final String lastSynced;
  final String helpTitle;
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return SettingsGroup(
      header: title,
      footer: lastSynced,
      children: [
        _InputRow(
          controller: controller,
          onChanged: onChanged,
          icon: icon,
          iconColor: iconColor,
          hint: hint,
          keyboardType: TextInputType.url,
          trailing: IconButton(
            tooltip: 'Link törlése',
            icon: Icon(Icons.close_rounded, color: scheme.onSurfaceVariant),
            onPressed: () {
              controller.clear();
              onChanged?.call('');
            },
          ),
        ),
        SettingsTile(
          icon: Icons.help_outline_rounded,
          iconColor: scheme.outline,
          title: helpTitle,
          external: true,
          onTap: () {},
        ),
      ],
    );
  }
}

class _InputRow extends StatelessWidget {
  const _InputRow({
    required this.icon,
    required this.hint,
    this.iconColor,
    this.keyboardType,
    this.trailing,
    required this.controller,
    this.onChanged,
  });

  final IconData icon;
  final String hint;
  final Color? iconColor;
  final TextInputType? keyboardType;
  final Widget? trailing;
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(left: AppSpacing.lg),
      child: Row(
        children: [
          Icon(icon, color: iconColor ?? scheme.onSurfaceVariant),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: TextField(
              keyboardType: keyboardType,
              autocorrect: false,
              controller: controller,
              onChanged: onChanged,
              decoration: InputDecoration(
                hintText: hint,
                border: InputBorder.none,
              ),
            ),
          ),
          if (trailing != null) trailing! else const SizedBox(width: AppSpacing.lg),
        ],
      ),
    );
  }
}
