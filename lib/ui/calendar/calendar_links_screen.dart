// lib/ui/calendar/calendar_links_screen.dart
import 'package:flutter/material.dart';
import 'package:itk_app/data/repositories/calendar_links_repository.dart';
import 'package:itk_app/data/repositories/calendar_repository.dart';
import 'package:itk_app/domain/models/calendar_link.dart';
import 'package:itk_app/ui/calendar/widgets/calendar_link_tile.dart';
import 'package:itk_app/ui/calendar/viewmodels/calendar_links_viewmodel.dart';
import 'package:itk_app/ui/core/theme/app_spacing.dart';
import 'package:itk_app/ui/core/theme/app_themes.dart';
import 'package:itk_app/ui/core/widgets/brand_appbar.dart';
import 'package:itk_app/ui/core/widgets/brand_button.dart';
import 'package:itk_app/ui/core/widgets/confirm_dialog.dart';
import 'package:itk_app/ui/core/widgets/grouped_list.dart';
import 'package:itk_app/ui/core/widgets/state_message.dart';
import 'package:itk_app/utils/context_extensions.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';

class CalendarLinksScreen extends StatefulWidget {
  const CalendarLinksScreen({super.key});

  static const _presets = ['Neptun', 'Moodle'];

  @override
  State<CalendarLinksScreen> createState() => _CalendarLinksScreenState();
}

class _CalendarLinksScreenState extends State<CalendarLinksScreen> {
  late final CalendarLinksViewmodel _viewModel;
  final _nameController = TextEditingController();
  final _urlController = TextEditingController();

  static final _skeletonLinks = List.generate(
    2,
    (index) => CalendarLink(
      id: index,
      name: BoneMock.words(2),
      url: '',
      syncInterval: SyncInterval.daily,
    ),
  );

  @override
  void initState() {
    super.initState();
    _viewModel = CalendarLinksViewmodel(
      repository: context.read<CalendarLinksRepository>(),
      calendarRepository: context.read<CalendarRepository>(),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _urlController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _add() async {
    await _viewModel.add.execute();
    if (!mounted) return;
    final error = _viewModel.add.errorMessage;

    if (error != null) {
      context.showMessage(error);
      return;
    }

    _nameController.clear();
    _urlController.clear();
    context.showMessage('Naptár hozzáadva!');
  }

  Future<void> _delete(int id) async {
    await _viewModel.delete.execute(id);
    if (!mounted) return;
    final error = _viewModel.delete.errorMessage;

    if (error != null) {
      context.showMessage(error);
      return;
    }

    context.showMessage('Naptár törölve!');
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return ListenableBuilder(
      listenable: Listenable.merge([
        _viewModel,
        _viewModel.load,
        _viewModel.add,
        _viewModel.delete,
      ]),
      builder: (context, v_) {
        final links = _viewModel.initialLoading ? _skeletonLinks : _viewModel.links;
        final loadError = _viewModel.load.errorMessage;
        final showError = loadError != null && _viewModel.links.isEmpty && !_viewModel.initialLoading;

        return Scaffold(
          appBar: buildBrandAppBar(context: context, title: 'Naptárlinkek'),
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
                style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Linked calendars

              SettingsGroup(
                header: 'Naptáraim',
                footer: 'Az órarended ezekből a naptárakból áll össze.',
                children: [
                  if (showError)
                    Padding(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      child: StateMessage(
                        icon: Icons.cloud_off_rounded,
                        message: loadError,
                        onRetry: () => _viewModel.load.execute(),
                      ),
                    )
                  else
                    for (final link in links)
                      Skeletonizer(
                        enabled: _viewModel.initialLoading,
                        child: CalendarLinkTile(
                          link: link,
                          onDismissed: (_) => _delete(link.id),
                          confirmDismiss: (_) async =>
                              await showConfirmDialog(
                                context,
                                title: 'Naptár törlése',
                                message: 'Biztosan törölni szeretnéd ezt a naptárat?',
                                confirmLabel: 'Törlés',
                                isDestructive: true,
                              ) ==
                              true,
                        ),
                      ),
                ],
              ),

              // Add
              SettingsGroup(
                header: 'Új naptár hozzáadása',
                footer: 'https:// vagy webcal:// kezdetű, .ics naptárlinket adj meg.',
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      AppSpacing.md,
                      AppSpacing.lg,
                      0,
                    ),
                    child: Wrap(
                      spacing: AppSpacing.sm,
                      children: [
                        for (final preset in CalendarLinksScreen._presets)
                          ActionChip(
                            label: Text(preset),
                            onPressed: () {
                              _nameController.text = preset;
                              _viewModel.setName(preset);
                            },
                          ),
                      ],
                    ),
                  ),
                  _InputRow(
                    icon: Icons.label_outline_rounded,
                    hint: 'Név, pl. Neptun',
                    onChanged: _viewModel.setName,
                    controller: _nameController,
                  ),
                  _InputRow(
                    icon: Icons.link_rounded,
                    hint: 'https://…/calendar.ics',
                    keyboardType: TextInputType.url,
                    onChanged: _viewModel.setUrl,
                    controller: _urlController,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: SegmentedButton<SyncInterval>(
                      showSelectedIcon: false,
                      segments: [
                        for (final interval in SyncInterval.values) ButtonSegment(value: interval, label: Text(interval.label)),
                      ],
                      selected: {_viewModel.syncInterval},
                      onSelectionChanged: (selection) => _viewModel.setSyncInterval(selection.first),
                    ),
                  ),
                ],
              ),
              BrandButton(
                onTap: _viewModel.canAdd ? _add : null,
                height: 52,
                backgroundColor: itkPrimary,
                child: const Center(
                  child: Text(
                    'Hozzáadás',
                    style: TextStyle(
                      color: itkDark,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _InputRow extends StatelessWidget {
  const _InputRow({
    required this.icon,
    required this.hint,
    this.keyboardType,
    required this.controller,
    this.onChanged,
  });

  final IconData icon;
  final String hint;
  final TextInputType? keyboardType;
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Row(
        children: [
          Icon(icon, color: scheme.onSurfaceVariant),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              keyboardType: keyboardType,
              autocorrect: false,
              decoration: InputDecoration(
                hintText: hint,
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
