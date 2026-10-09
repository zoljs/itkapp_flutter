import 'package:flutter/material.dart';
import 'package:itk_app/data/services/midterms_service.dart';
import 'package:itk_app/domain/models/subject.dart';
import 'package:itk_app/ui/core/theme/app_spacing.dart';
import 'package:itk_app/ui/core/widgets/adaptive_date_picker.dart';
import 'package:itk_app/ui/core/widgets/adaptive_sheet.dart';
import 'package:itk_app/ui/core/widgets/grouped_list.dart';
import 'package:itk_app/ui/core/widgets/brand_appbar.dart';
import 'package:itk_app/ui/midterms/subject_picker_screen.dart';
import 'package:itk_app/utils/context_extensions.dart';
import 'package:itk_app/utils/result.dart';

class AddMidtermScreen extends StatefulWidget {
  const AddMidtermScreen({super.key, this.scrollController});

  final ScrollController? scrollController;

  @override
  State<AddMidtermScreen> createState() => _AddMidtermScreenState();
}

class _AddMidtermScreenState extends State<AddMidtermScreen> {
  final _locationController = TextEditingController();

  Subject? _subject;
  DateTime? _date;
  TimeOfDay? _time;
  bool _saving = false;

  @override
  void dispose() {
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _pickSubject() async {
    final picked = await Navigator.push<Subject>(
      context,
      MaterialPageRoute(
        builder: (_) => SubjectPickerScreen(
          selectedId: _subject?.id,
          scrollController: widget.scrollController,
        ),
      ),
    );
    if (picked != null) setState(() => _subject = picked);
  }

  Future<void> _pickDate() async {
    final picked = await showAdaptiveDatePicker(
      context: context,
      initialDate: _date,
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showAdaptiveTimePicker(
      context: context,
      initialTime: _time ?? const TimeOfDay(hour: 8, minute: 0),
    );
    if (picked != null) setState(() => _time = picked);
  }

  Future<void> _save() async {
    if (_saving) return;

    final subject = _subject;
    final date = _date;
    final time = _time;
    if (subject == null || date == null || time == null) {
      context.showMessage('Válassz tárgyat, dátumot és időpontot.');
      return;
    }

    setState(() => _saving = true);

    final location = _locationController.text.trim();
    final result = await MidtermsService.instance.addMidterm(
      subjectId: subject.id,
      startsAt:
          DateTime(date.year, date.month, date.day, time.hour, time.minute),
      location: location.isEmpty ? null : location,
    );
    if (!mounted) return;

    switch (result) {
      case Ok():
        closeSheet(context);
      case Err(:final message):
        setState(() => _saving = false);
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
                value: _subject?.name ?? 'Válassz',
                onTap: _pickSubject,
              ),
            ],
          ),
          SettingsGroup(
            header: 'Időpont',
            children: [
              SettingsTile(
                title: 'Dátum',
                value: _date == null
                    ? 'Válassz'
                    : localizations.formatMediumDate(_date!),
                onTap: _pickDate,
              ),
              SettingsTile(
                title: 'Kezdés',
                value: _time == null ? 'Válassz' : _time!.format(context),
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
    return Scaffold(
      backgroundColor: sheetBackgroundColor(context),
      appBar: buildBrandAppBar(
        context: context,
        title: 'Új ZH',
        closesSheet: true,
        actionIcon: Icons.check,
        onAction: _save,
      ),
      body: _buildForm(context),
    );
  }
}
