import 'package:flutter/material.dart';
import 'package:itk_app/data/services/midterms_service.dart';
import 'package:itk_app/data/services/subjects_service.dart';
import 'package:itk_app/domain/models/subject.dart';
import 'package:itk_app/ui/core/theme/app_spacing.dart';
import 'package:itk_app/ui/core/widgets/ack_appbar.dart';
import 'package:itk_app/ui/core/widgets/adaptive_date_picker.dart';
import 'package:itk_app/ui/core/widgets/grouped_list.dart';
import 'package:itk_app/ui/core/widgets/state_message.dart';
import 'package:itk_app/utils/context_extensions.dart';
import 'package:itk_app/utils/result.dart';

class AddMidtermScreen extends StatefulWidget {
  const AddMidtermScreen({super.key});

  @override
  State<AddMidtermScreen> createState() => _AddMidtermScreenState();
}

class _AddMidtermScreenState extends State<AddMidtermScreen> {
  final _locationController = TextEditingController();

  List<Subject> _subjects = const [];
  bool _loading = true;
  String? _error;

  Subject? _subject;
  DateTime? _date;
  TimeOfDay? _time;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadSubjects();
  }

  @override
  void dispose() {
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _loadSubjects() async {
    setState(() {
      _error = null;
      _loading = true;
    });

    final result = await SubjectsService.instance.getSubjects();
    if (!mounted) return;

    switch (result) {
      case Ok(:final value):
        setState(() {
          _subjects = value;
          _loading = false;
        });
      case Err(:final message):
        setState(() {
          _error = message;
          _loading = false;
        });
    }
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
        Navigator.pop(context);
      case Err(:final message):
        setState(() => _saving = false);
        context.showMessage(message);
    }
  }

  Widget _buildForm(BuildContext context) {
    final localizations = MaterialLocalizations.of(context);

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
            header: 'Tárgy',
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.sm,
                ),
                child: DropdownMenu<Subject>(
                  hintText: 'Keresés kód vagy név alapján...',
                  expandedInsets: EdgeInsets.zero,
                  enableFilter: true,
                  requestFocusOnTap: true,
                  menuHeight: 300,
                  inputDecorationTheme: const InputDecorationTheme(
                    border: InputBorder.none,
                  ),
                  onSelected: (s) => setState(() => _subject = s),
                  dropdownMenuEntries: [
                    for (final s in _subjects)
                      DropdownMenuEntry(
                        value: s,
                        label: '${s.code} – ${s.name}',
                      ),
                  ],
                ),
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
    final scheme = Theme.of(context).colorScheme;

    final Widget body;
    if (_loading) {
      body = const Center(child: RefreshProgressIndicator());
    } else if (_error != null) {
      body = StateMessage(
        icon: Icons.cloud_off_rounded,
        message: _error!,
        onRetry: _loadSubjects,
      );
    } else {
      body = _buildForm(context);
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: buildAckAppBar(
        context: context,
        scheme: scheme,
        title: const Text('Új ZH'),
        onPressed: _save,
      ),
      body: body,
    );
  }
}
