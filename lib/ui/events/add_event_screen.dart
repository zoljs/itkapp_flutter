import 'package:flutter/material.dart';
import 'package:itk_app/data/repositories/event_repository.dart';
import 'package:itk_app/domain/models/event.dart';
import 'package:itk_app/domain/models/subject.dart';
import 'package:itk_app/ui/core/theme/app_spacing.dart';
import 'package:itk_app/ui/core/widgets/adaptive_date_picker.dart';
import 'package:itk_app/ui/core/widgets/adaptive_segmented_control.dart';
import 'package:itk_app/ui/core/widgets/adaptive_sheet.dart';
import 'package:itk_app/ui/core/widgets/grouped_list.dart';
import 'package:itk_app/ui/core/widgets/brand_appbar.dart';
import 'package:itk_app/ui/core/screens/subject_picker_screen.dart';
import 'package:itk_app/ui/events/viewmodels/add_event_viewmodel.dart';
import 'package:itk_app/utils/context_extensions.dart';
import 'package:provider/provider.dart';

class AddEventScreen extends StatefulWidget {
  const AddEventScreen({super.key, this.scrollController, required this.types, required this.eventLabel});

  final String eventLabel;
  final Set<EventType> types;
  final ScrollController? scrollController;

  @override
  State<AddEventScreen> createState() => _AddEventScreenState();
}

class _AddEventScreenState extends State<AddEventScreen> {
  final _locationController = TextEditingController();
  late final AddEventViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = AddEventViewModel(repository: context.read<EventRepository>(), allowedTypes: widget.types);
  }

  @override
  void dispose() {
    _locationController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _pickSubject() async {
    final picked = await Navigator.push<Subject>(
      context,
      MaterialPageRoute(
        builder: (_) => SubjectPickerScreen(
          selectedId: _viewModel.subject?.id,
          scrollController: widget.scrollController,
        ),
      ),
    );
    if (picked != null) _viewModel.setSubject(picked);
  }

  Future<void> _pickDate() async {
    final picked = await showAdaptiveDatePicker(
      context: context,
      initialDate: _viewModel.date ?? DateTime.now(),
    );
    if (picked != null) _viewModel.setDate(picked);
  }

  Future<void> _pickTime() async {
    final picked = await showAdaptiveTimePicker(
      context: context,
      initialTime: _viewModel.time ?? const TimeOfDay(hour: 8, minute: 0),
    );
    if (picked != null) _viewModel.setTime(picked);
  }

  Future<void> _submit() async {
    await _viewModel.save.execute();
    if (!mounted) return;

    if (_viewModel.save.completed) {
      closeSheet(context);
    } else if (_viewModel.save.errorMessage case final message?) {
      context.showMessage(message);
    }
  }

  Widget _buildForm(BuildContext context) {
    final localizations = MaterialLocalizations.of(context);

    return SingleChildScrollView(
      controller: widget.scrollController,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.xxxl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SettingsGroup(
            header: 'Tárgy',
            children: [
              SettingsTile(
                title: 'Tárgy',
                value: _viewModel.subject?.name ?? 'Válassz',
                onTap: _pickSubject,
              ),
            ],
          ),
          if (widget.types.length > 1)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SettingsHeader(title: 'Típus'),
                  AdaptiveSegmentedControl(
                    values: widget.types.toList(),
                    selected: _viewModel.type,
                    onChanged: _viewModel.setType,
                    labelOf: (item) => item.label,
                  ),
                ],
              ),
            ),
          SettingsGroup(
            header: 'Időpont',
            children: [
              SettingsTile(
                title: 'Dátum',
                value: _viewModel.date == null ? 'Válassz' : localizations.formatMediumDate(_viewModel.date!),
                onTap: _pickDate,
              ),
              SettingsTile(
                title: 'Kezdés',
                value: _viewModel.time == null ? 'Válassz' : _viewModel.time!.format(context),
                onTap: _pickTime,
              ),
            ],
          ),
          SettingsGroup(
            header: 'Helyszín',
            footer: 'Opcionális. Később is megadható, ha még nem ismert.',
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: TextField(
                  controller: _locationController,
                  maxLength: 100,
                  onChanged: _viewModel.setLocation,
                  decoration: const InputDecoration(
                    hintText: 'pl. 201-es terem',
                    border: InputBorder.none,
                    counterText: '',
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
        listenable: Listenable.merge([_viewModel, _viewModel.save]),
        builder: (context, _) {
          return Scaffold(
            backgroundColor: sheetBackgroundColor(context),
            appBar: buildBrandAppBar(
              context: context,
              title: 'Új ${widget.eventLabel}',
              closesSheet: true,
              actionIcon: Icons.check,
              onAction: _viewModel.canSave && !_viewModel.save.running ? _submit : null,
            ),
            body: _buildForm(context),
          );
        });
  }
}
